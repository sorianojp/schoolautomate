 <%@ page language="java" import="utility.*,java.util.Vector, payroll.PayrollSheet, 
																 payroll.PReDTRME, payroll.OvertimeMgmt" %>
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
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 10px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

<%
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheetprint","payroll_sheet_print.jsp");
								
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
														"payroll_sheet_print.jsp");
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
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	PayrollSheet RptPSheet = new PayrollSheet(request);
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strPayrollPeriod  = null;
	Vector vRows  = null;
	Vector vEarnCols = null;
	Vector vDedCols  = null;
	Vector vEarnDedCols  = null;
	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vEarnDed = null;

	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	Vector vEmpOT = null;
	Vector vEmpAdjust = null;

	int iCols  = 0;

	double dBasic = 0d;
	double dTemp = 0d;
	double dExtraTotal = 0d;
	double dExtraAllow = 0d;	
	double dTotalSalary = 0d;			
	double dTotalBasic = 0d;
	double dTotalCola = 0d;
	double dOtherTotal = 0d;
	double dTotalAbsences = 0d;
	double dTotalGross = 0d;
	double dTotalSSS = 0d;
	double dTotalHdmf = 0d;
	double dTotalTax = 0d;
	double dTotalAdv = 0d;
	double dOtherDed = 0d;

	double dTempOthers = 0d;
	double dEmpDeduct = 0d;
	double dTotalDeductions = 0d;
	double dTotalNet = 0d;	
	double dTotalAdjust = 0d;
	
		
	double dLineTotal = 0d;
	boolean bolPageBreak = false;
	int i = 0;
	int iColCounter = 0;
	int iFieldCount = 75;// number of fields in the vector..
	String strEmployerIndex = WI.fillTextValue("employer_index");
	Vector vEmployerInfo = null;
	vEmployerInfo = new payroll.PRRemittance(request).operateOnEmployerProfile(dbOP, 3, strEmployerIndex);
	if (vEmployerInfo == null || vEmployerInfo.size() == 0) {
		strErrMsg = "Employer profile not found";
	}
	
	//vRetResult = RptPay.generatePayrollSheet(dbOP);
	vRetResult = RptPSheet.getPSheetItems(dbOP);
	//System.out.println("vRetResult " +vRetResult);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
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

	int iNumRec = 0;//System.out.println(vRetResult);
	int iTotalPages = (vRetResult.size())/(iFieldCount*iMaxRecPerPage);	
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;	
	
	int iOT = 0;
	int iIndex = 0;
	int iOTType = 0;
	int iAdjType =0;
	
		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);		
		vEarnDedCols = (Vector)vRetResult.elementAt(3);	
		
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);			
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
			//System.out.println("vOTTypes " + vOTTypes);
		
		if(WI.fillTextValue("hide_adjustment").equals("1"))
			vAdjTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, false);			
		else
			vAdjTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "0");
		
		if(vEarnCols != null && vEarnCols.size() > 0)
			iEarnColCount = vEarnCols.size() - 2;
		 
 		if(vDedCols != null && vDedCols.size() > 0)
			iDedColCount = vDedCols.size() - 1;		
		 
 		if (vEarnDedCols != null && vEarnDedCols.size() > 0)
			 iEarnDedCount = vEarnDedCols.size() - 1;	

 		if (vOTTypes != null && vOTTypes.size() > 0)
			iOTType = vOTTypes.size()/19;

 		if (vAdjTypes != null && vAdjTypes.size() > 0)
			iAdjType = vAdjTypes.size()/19;

			 
 	double[] adEarningTotal = new double[iEarnColCount];
	double[] adDeductTotal = new double[iDedColCount];
	double[] adEarnDedTotal = new double[iEarnDedCount];
	
	double[] adTotalOT = new double[iOTType];	
	double[] adTotalAdj = new double[iAdjType];	
		
	if((vRows.size() % (iFieldCount*iMaxRecPerPage)) > 0) 
		 ++iTotalPages;

	 for (;iNumRec < vRows.size();iPage++){
	 	dBasic = 0d;
		dTemp = 0d;
		dExtraTotal = 0d;
		dExtraAllow = 0d;
		dTotalSalary = 0d;			
		dTotalBasic = 0d;
		dTotalCola = 0d;
		dOtherTotal = 0d;
		dTotalAbsences = 0d;
		dTotalGross = 0d;
		dTotalSSS = 0d;
		dTotalHdmf = 0d;		
		dTotalTax = 0d;
		dTotalAdv = 0d;
	 
		dTempOthers = 0d;
		dEmpDeduct = 0d;
		dTotalDeductions = 0d;
		dTotalNet = 0d;	
		dTotalAdjust = 0d;
		
		dLineTotal = 0d;
		
		// reset the page total 
		for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
			adEarningTotal[iCols-2] = 0d;	
		}
		 				 
		for(iCols = 1;iCols <= iDedColCount; iCols++){
		 adDeductTotal[iCols-1] = 0d;
		}
		
		for(iCols = 1;iCols <= iEarnDedCount; iCols++){
		 adEarnDedTotal[iCols-1] = 0d;
		}
%>
<body onLoad="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="54" colspan="5" align="center">
        <%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);					
				%>
        <font size="2"><strong><%=strTemp%></strong></font>
				<%strTemp = "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";%>
				<%=strTemp%>				
        <%}else{%>
					<font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font>
        <%}%> 
				<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="TOPRIGHT">
          <tr>
            
						<td height="24" colspan="<%= iEarnColCount + (iDedColCount/2) + iEarnDedCount + 20 + iOTType + iAdjType%>" align="center" class="BOTTOMLEFT"><strong>PAYROLL 
              SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>
      			<!--
						<td height="24" colspan="26" align="center" class="BOTTOMLEFT"><strong><font color="#0000FF">PAYROLL 
						SHEET FOR SALARY SCHEDULE : <%//=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>						
						-->        
          </tr>
          <tr>
						<td colspan="<%=iEarnColCount + iEarnDedCount + 13 + iOTType + iAdjType%>" class="headerBOTTOMLEFT">&nbsp;<%=WI.fillTextValue("college_name")%> <%=WI.getStrValue(WI.fillTextValue("dept_name"),"(",")","")%></td>
            <td colspan="<%=(iDedColCount/2) + 5%>" align="center" class="BOTTOMLEFT"><strong>D E D U C T I O N S </strong></td>
    				<!--
						<td colspan="17" class="headerBOTTOMLEFT">&nbsp; </td>
						<td colspan="6" align="center" class="BOTTOMLEFT"><strong>D E D U C T I O N S </strong></td>					
						-->          
            <td class="headerBOTTOMLEFT">&nbsp;</td>
          </tr>
          <tr>
            	<td height="20" colspan="2" class="BOTTOMLEFT"><font size="1">&nbsp;</font></td>
              <td colspan="7" align="center" class="BOTTOMLEFT"><strong><font size="1">PART TIME / 
                EXTRA LOAD</font></strong></td>
              
							<td colspan="<%=(iEarnColCount + iEarnDedCount + 4 + iOTType + iAdjType)%>" class="BOTTOMLEFT">&nbsp;</td>
              <td colspan="<%=((iDedColCount/2) + 5)%>" class="BOTTOMLEFT">&nbsp;</td>
      			<!--	
						<td colspan="8" class="BOTTOMLEFT">&nbsp;</td>
						<td colspan="6" class="BOTTOMLEFT">&nbsp;</td>						
						-->        
            <td class="BOTTOMLEFT">&nbsp;</td>
          </tr>
          <tr>
            <td width="13%" height="33" align="center" class="headerBOTTOMLEFT"><strong>EMPLOYEE 
              NAME</strong></td>
              <%
				if(WI.fillTextValue("is_weekly").equals("1"))
					strTemp = "WEEKLY";
				else
					strTemp = "QUINCINA";
			%>
            <td width="4%" align="center" class="headerBOTTOMLEFT"><%=strTemp%> SALARY</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">LEC. 
                HOUR (inside)</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">LAB. 
                HOUR (inside)</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">TOTAL 
                HOURS</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">LEC. 
                HOUR (outside)</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">LAB. 
                HOUR (outside)</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">TOTAL 
                HOURS</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">SUB 
                TOTAL SALARY</td>
              <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){%>
            <td width="3%" align="center" class="headerBOTTOMLEFT">&nbsp;<%=(String)vEarnCols.elementAt(iCols)%></td>
              <%}%>
            <td width="3%" align="center" class="headerBOTTOMLEFT">COLA</td>
						<%
						if(vOTTypes != null && vOTTypes.size() > 0){
						for(iOT = 0; iOT < vOTTypes.size(); iOT+=19){
							strTemp = (String)vOTTypes.elementAt(iOT+1);
						%>								
						<td width="3%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
						<%}						
						}%>
						<td width="3%" align="center" class="headerBOTTOMLEFT">OTHERS</td>
						<%
						if(vAdjTypes != null && vAdjTypes.size() > 0){
						for(iOT = 0; iOT < vAdjTypes.size(); iOT+=19){
							strTemp = (String)vAdjTypes.elementAt(iOT+1);
						%>							
						<td width="3%" align="center" class="headerBOTTOMLEFT"><%=strTemp%></td>
						<%}
						}%>									
              <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){%>
            <td align="center" class="headerBOTTOMLEFT"><%=(String)vEarnDedCols.elementAt(iCols)%></td>
              <%}%>
            <td width="3%" align="center" class="headerBOTTOMLEFT">ABSENCES</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">GROSS 
                SALARY</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">SSS 
                &amp; MED. </td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">HDMF</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">TAX</td>
              <%			
			for(iCols = 1;iCols <= iDedColCount; iCols +=2){
				strTemp = (String)vDedCols.elementAt(iCols);
			%>
            <td width="2%" align="center" class="headerBOTTOMLEFT">&nbsp;<%=strTemp%></td>
              <%}%>
            <td width="4%" align="center" class="headerBOTTOMLEFT">ADVANCE 
              &amp; OTHER DED</td>
              <td width="3%" align="center" class="headerBOTTOMLEFT">TOTAL 
                DEDUCT</td>
              <td width="4%" align="center" class="headerBOTTOMLEFT">NET 
                SALARY</td>
          </tr>
          <% 
		for(iCount = 1;iNumRec<vRows.size(); iNumRec+=iFieldCount,++iCount){
			dLineTotal = 0d;
			dBasic = 0d;
			dEmpDeduct = 0d;
			dOtherDed = 0d;
			dTempOthers =0d;
		
			i = iNumRec;
			vEarnings   = (Vector)vRows.elementAt(i+53);
			vDeductions = (Vector)vRows.elementAt(i+54);
			vEarnDed    = (Vector)vRows.elementAt(i+59);		
			vEmpOT = (Vector)vRows.elementAt(i+65);
			vEmpAdjust = (Vector)vRows.elementAt(i+67);					
			
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			

		%>
          <tr>
            <td height="20" class="BOTTOMLEFT"><strong><%=WI.formatName((String)vRows.elementAt(i+4), (String)vRows.elementAt(i+5),
							(String)vRows.elementAt(i+6), 9)%></strong></td>
              <%
		dBasic = 0d;
	  	if (vRows.elementAt(i+7) != null){	
			strTemp = (String) vRows.elementAt(i+7); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dBasic = Double.parseDouble(strTemp);
			}
		}
		dTotalBasic += dBasic;
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dBasic,true),"&nbsp;")%></td>
              <!--// excess lec in -->
            <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+15); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <!--// excess lab in -->
            <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+16); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <%
	  	// excess lecture hours inside office hours
	  	dTemp = 0d;
	  	if (vRows.elementAt(i+15) != null){	
			strTemp = (String) vRows.elementAt(i+15); 
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		 // excess lab hours inside office hours
	  	if (vRows.elementAt(i+16) != null){
			strTemp = (String) vRows.elementAt(i+16); 			
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp)/2;
			}
		}
		strTemp = Double.toString(dTemp);
	  %>
            <!--total hours inside office hours-->
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+18); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
            <!--Excess lec out-->
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <!--Excess lab out-->
            <%
	  	dTemp = 0d;
		strTemp = (String) vRows.elementAt(i+19); 
		dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp == 0d)
			strTemp = "";
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <%
	  	dTemp = 0d;
	  	if (vRows.elementAt(i+18) != null){	
			strTemp = (String) vRows.elementAt(i+18); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
	  	if (vRows.elementAt(i+19) != null){
			strTemp = (String) vRows.elementAt(i+19); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp)/2;
			}
		}
		strTemp = Double.toString(dTemp);
	  %>
            <!--total Excess out-->
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <%
	  	dTemp = 0d;
			// faculty salary 
	  	if (vRows.elementAt(i+30) != null){	
			strTemp = (String) vRows.elementAt(i+30); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		
				// overload_amt
		if (vRows.elementAt(i+22) != null){	
			strTemp = (String)vRows.elementAt(i+22); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dExtraTotal += dTemp;
		dLineTotal += dTemp;
		strTemp = Double.toString(dTemp);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
            <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){
							strTemp = (String)vEarnings.elementAt(iCols);			
							dTemp = Double.parseDouble(strTemp);
							dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
							adEarningTotal[iCols-2] = adEarningTotal[iCols-2] + dTemp;
							dLineTotal += dTemp;
							if(strTemp.equals("0"))
								strTemp = "";			
						%>
            <td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
              <%}%>
            <%
	  	dTemp = 0d;
			// COLA
	  	if (vRows.elementAt(i+25) != null){	
			strTemp = (String)vRows.elementAt(i+25); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dTotalCola += dTemp;
		dLineTotal += dTemp;
		strTemp = Double.toString(dTemp);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
						<%
						if(vOTTypes != null && vOTTypes.size() > 0){
						 for(iOT = 0, iCols = 0;iOT < vOTTypes.size(); iOT+=19, iCols++){
							 strTemp = null;
							 iIndex = vEmpOT.indexOf((Integer)vOTTypes.elementAt(iOT));
							 if(iIndex != -1){
								 strTemp = (String)vEmpOT.elementAt(iIndex+2);					 
							 }
			
							dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
							adTotalOT[iCols] = adTotalOT[iCols] + dTemp;
							dLineTotal += dTemp;
							strTemp = CommonUtil.formatFloat(dTemp,true);
							if(dTemp == 0d)
								strTemp = "&nbsp;";
						%>
							<td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
							<%}
							}%>									
              <%			
			if(vEarnings != null){
				// subject allowances 
				strTemp = (String)vEarnings.elementAt(0); 
				if (strTemp.length() > 0){
					dTempOthers = Double.parseDouble(strTemp);
				}
				// ungrouped earnings.
				strTemp = (String)vEarnings.elementAt(1); 
				if (strTemp.length() > 0){
					dTempOthers += Double.parseDouble(strTemp);
				}				
			}

		// ot_amt
		if (vRows.elementAt(i+23) != null){	
			strTemp = (String)vRows.elementAt(i+23); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		// night_diff_amt
		if (vRows.elementAt(i+24) != null){	
			strTemp = (String)vRows.elementAt(i+24); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		
		// holiday_pay_amt
		if (vRows.elementAt(i+26) != null){	
			strTemp = (String)vRows.elementAt(i+26); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		// addl_payment_amt 
		if (vRows.elementAt(i+27) != null){	
			strTemp = (String)vRows.elementAt(i+27); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}

		// Adhoc Allowances
		if (vRows.elementAt(i+28) != null){	
			strTemp = (String)vRows.elementAt(i+28); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}

		// addl_resp_amt
		if (vRows.elementAt(i+29) != null){	
			strTemp = (String)vRows.elementAt(i+29); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}
		
		// substitute salary
		if (vRows.elementAt(i+38) != null){	
			strTemp = (String)vRows.elementAt(i+38); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTempOthers += Double.parseDouble(strTemp);
			}
		}						
		dTempOthers = CommonUtil.formatFloatToCurrency(dTempOthers,2);		
		dLineTotal += dTempOthers;
		dOtherTotal +=dTempOthers;				
		strTemp = Double.toString(dTempOthers);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
              <%
	  	/*
			dTemp = 0d;
			// adjustment amount
	  	if (vRows.elementAt(i+51) != null){	
			strTemp = (String)vRows.elementAt(i+51); 
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dLineTotal += dTemp;
		dTotalAdjust += dTemp;
		*/
	  %>
		<%
			if(vAdjTypes != null && vAdjTypes.size() > 0){
			 for(iOT = 0, iCols = 0;iOT < vAdjTypes.size(); iOT+=19, iCols++){
				 strTemp = null;
				 iIndex = vEmpAdjust.indexOf((Integer)vAdjTypes.elementAt(iOT));
				 if(iIndex != -1){
					 strTemp = (String)vEmpAdjust.elementAt(iIndex+2);					 
				 }

				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
				adTotalAdj[iCols] = adTotalAdj[iCols] + dTemp;
 				strTemp = CommonUtil.formatFloat(dTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>		
		 <td align="right" class="BOTTOMLEFT"><%=strTemp%></td>
      <%}
			}%>
              <%for(iCols = 1;iCols <= iEarnDedCount; iCols ++){
		strTemp = (String)vEarnDed.elementAt(iCols);			
		dTemp = Double.parseDouble(strTemp);
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dLineTotal -= dTemp;
		adEarnDedTotal[iCols-1] = adEarnDedTotal[iCols-1] + dTemp;
		if(strTemp.equals("0"))
			strTemp = "";			
	%>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"")%></td>
              <%}%>
            <%
			
	  	dTemp = 0d;
		// late_under_amt
		if (vRows.elementAt(i+48) != null){	
			strTemp = (String)vRows.elementAt(i+48); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}

		//faculty_absence
	  	if (vRows.elementAt(i+49) != null){	
			strTemp = (String)vRows.elementAt(i+49); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}

		//leave_deduction_amt
	  	if (vRows.elementAt(i+33) != null){	
			strTemp = (String)vRows.elementAt(i+33); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}

		//awol_amt
	  if (vRows.elementAt(i+47) != null){	
			strTemp = (String)vRows.elementAt(i+47); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dTotalAbsences += dTemp;
		dLineTotal -= dTemp;
		strTemp = Double.toString(dTemp);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
      <%
	  	dLineTotal += dBasic;
			dTotalGross += dLineTotal;
			%>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"&nbsp;")%></td>
              <%
	  	// sss contribution
		dTemp = 0d;
	  	if (vRows.elementAt(i+39) != null){	
			strTemp = (String)vRows.elementAt(i+39); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
	  	// phealth contribution	
		if (vRows.elementAt(i+40) != null){	
			strTemp = (String)vRows.elementAt(i+40); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp += Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dTotalSSS += dTemp;
		dEmpDeduct += dTemp;
		strTemp = Double.toString(dTemp);
//		System.out.println("SSS " +dTemp);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
              <%
	  	// hdmf contribution
	  	dTemp = 0d;
	  	if (vRows.elementAt(i+41) != null){	
			strTemp = (String)vRows.elementAt(i+41); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dTotalHdmf += dTemp;
		dEmpDeduct += dTemp;
		strTemp = Double.toString(dTemp);
//		System.out.println("hdmf " +dTemp);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
              <%
	  	dTemp = 0d;
		// tax
	  	if (vRows.elementAt(i+46) != null){	
			strTemp = (String)vRows.elementAt(i+46); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){
				dTemp = Double.parseDouble(strTemp);
			}
		}
		dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
		dTotalTax += dTemp;
		dEmpDeduct += dTemp;
		strTemp = Double.toString(dTemp);
//		System.out.println("Tax " +dTemp);
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%></td>
              <%for(iCols = 1;iCols <= iDedColCount/2; iCols++){
			strTemp = (String)vDeductions.elementAt(iCols);
			dTemp = Double.parseDouble(strTemp);
			dTemp = CommonUtil.formatFloatToCurrency(dTemp,2);
			dEmpDeduct += dTemp;
			adDeductTotal[iCols-1] = adDeductTotal[iCols-1] + dTemp;			
			if(dTemp == 0d)
				strTemp = "";			
		%>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
              <%}%>
            <%
			// this is the other ungrouped deductions
			strTemp = (String)vDeductions.elementAt(0);
			dTemp = Double.parseDouble(strTemp);
			dOtherDed += dTemp;
			
			// misc_deduction
		if (vRows.elementAt(i+45) != null){	
			strTemp = (String)vRows.elementAt(i+45); 
			strTemp = ConversionTable.replaceString(strTemp,",","");
			if (strTemp.length() > 0){				
				dOtherDed += Double.parseDouble(strTemp);				
			}
		}				
		dOtherDed = CommonUtil.formatFloatToCurrency(dOtherDed,2);
		dTotalAdv += dOtherDed;
		dEmpDeduct += dOtherDed;
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDed,true),"&nbsp;")%></td>
              <%
		  dTotalDeductions += dEmpDeduct;
	  %>
            <td align="right" class="BOTTOMLEFT"><%=WI.getStrValue(CommonUtil.formatFloat(dEmpDeduct,true),"&nbsp;")%></td>
              <%
	  	dTemp = 0d;
			// salary
	  	//if (vRows.elementAt(i+52) != null){	
			// strTemp = (String)vRows.elementAt(i+52); 
			// if (strTemp.length() > 0){
			// 	dTemp = Double.parseDouble(strTemp);
			// }
    	//}
	    dLineTotal = dLineTotal - dEmpDeduct;
		dLineTotal = CommonUtil.formatFloatToCurrency(dLineTotal,2);
		dTotalNet += dLineTotal;
	  %>
            <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
          </tr>
          <%} // end for loop%>
          <tr>
            <td height="20" class="BOTTOMLEFT"><div align="right"><font size="1"><strong>TOTAL :   </strong></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1">&nbsp;<%=WI.getStrValue(CommonUtil.formatFloat(dTotalBasic,true)," ")%></font></div></td>
              <td class="BOTTOMLEFT">&nbsp;</td>
              <td class="BOTTOMLEFT">&nbsp;</td>
              <td class="BOTTOMLEFT">&nbsp;</td>
              <td class="BOTTOMLEFT">&nbsp;</td>
              <td class="BOTTOMLEFT">&nbsp;</td>
              <td class="BOTTOMLEFT">&nbsp;</td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dExtraTotal,true)%></font></div></td>
              <%for(iCols = 2;iCols <= iEarnColCount + 1; iCols++){%>
            <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(adEarningTotal[iCols-2],true)%></font></div></td>
              <%}%>
            <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalCola,true)%></font></div></td>
						<% for(iCols = 0;iCols < iOTType; iCols++){%>
						<td class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adTotalOT[iCols],true)%></td>
						<%}%>
						<td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dOtherTotal,true)%></font></div></td>
						<% for(iCols = 0;iCols < iAdjType; iCols++){%>
						<td class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adTotalAdj[iCols],true)%></td>
						<%}%>						
						<%for(iCols = 1;iCols <= iEarnDedCount; iCols++){%>
            <td align="right" class="BOTTOMLEFT"><%=CommonUtil.formatFloat(adEarnDedTotal[iCols-1],true)%></td>
              <%}%>
            <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalAbsences,true)%></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalGross,true)%></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalSSS,true)%></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalHdmf,true)%></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalTax,true)%></font></div></td>
              <%for(iCols = 1;iCols <= iDedColCount/2; iCols++){%>
            <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%></font></div></td>
              <%}%>
            <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalAdv,true)%></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalDeductions,true)%></font></div></td>
              <td class="BOTTOMLEFT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalNet,true)%></font></div></td>
          </tr>
      </table></td></tr>
</table>  	
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td height="18" colspan="3" class="NoBorder">CERTIFIED CORRECT BY:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td rowspan="7" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="67%" class="NoBorder">SALARIES &amp; WAGES</td>
            <td width="33%" align="right" class="NoBorder"><%=CommonUtil.formatFloat(dTotalGross,true)%>&nbsp;</td>
          </tr>
          <tr> 
            <td class="NoBorder">SSS &amp; MED</td>
            <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dTotalSSS,true)%>&nbsp;</td>
          </tr>
          <tr> 
            <td class="NoBorder">W/HOLDING TAX</td>
            <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dTotalTax,true)%>&nbsp;</td>
          </tr>
          <tr> 
            <td class="NoBorder">HDMF</td>
            <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dTotalHdmf,true)%>&nbsp;</td>
          </tr>
          
					<%						
					for(iCols = 1,iColCounter = 1;iColCounter <= iDedColCount; iCols++, iColCounter+=2){ 
						strTemp = (String)vDedCols.elementAt(iColCounter);
					%> 
          <tr> 
            <td class="NoBorder"><%=strTemp%></td>
            <td align="right" class="NoBorder"><%=CommonUtil.formatFloat(adDeductTotal[iCols-1],true)%>&nbsp;</td>
          </tr>
					<%}%>			
          <tr> 
            <td class="NoBorder">ADV'S TO EMPS</td>
            <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dTotalAdv,true)%>&nbsp;</td>
          </tr>
          <tr> 
            <td class="NoBorder">CASH IN BANK</td>
            <td align="right" class="NoBorder">&nbsp;<%=CommonUtil.formatFloat(dTotalNet,true)%>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"><div align="center"><font size="1"><strong><%=WI.fillTextValue("accounting_head").toUpperCase()%><br>
          </strong>HEAD, ACCOUNTING SECTION </font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("benefit_head").toUpperCase()%><br>
          </font></strong><font size="1">HEAD, BENEFIT SECTION </font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><font size="1"><strong><%=WI.fillTextValue("payroll_head").toUpperCase()%></strong><br>
          HEAD, PAYROLL SECTION </font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="14">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3"><font size="1"><strong>APPROVED FOR PAYMENT</strong></font></td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top" class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="3" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("president").toUpperCase()%><br>
      </font></strong><font size="1">PRESIDENT</font></div></td>
      <td>&nbsp;</td>
      <td colspan="2" valign="top"><div align="center"><strong><font size="1"><%=WI.fillTextValue("vp_finance").toUpperCase()%><br>
          </font></strong><font size="1">CTTP/VP-Finance</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" height="18">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
    </tr>
  </table>	
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
 } //end end upper most if (vRetResult !=null)%>
 <input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>