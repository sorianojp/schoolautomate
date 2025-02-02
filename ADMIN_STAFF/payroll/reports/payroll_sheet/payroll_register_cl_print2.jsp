<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary by Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.NoBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }	
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 10px;
    }
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 10px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 10px;
    }
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 8px;
    }    
	TD.thinborder {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;	
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-payrollsheet","payroll_register_cl.jsp");
								
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
														"payroll_register_cl.jsp");
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
	String strPayEnd = null;
	String strTemp2 = null;
	boolean bolPageBreak  = false;
	int iFieldCount = 50;// number of fields in the vector..
	int iStart = 23; // starting null... refer to java file
	int i = 0;

	double dBasic = 0d;
	double dDaysWorked = 0d;
	double dTemp = 0d;
	double dLineOver = 0d;
	
	double dTotalBasic = 0d;
	double dTotalAdjust = 0d;	
	double dTotalMeal  = 0d;	
	double dHoursOver = 0d;
	double dTotalOverLoad = 0d;
			
	double dTotalSalary = 0d;
	double dTotalRegOtHr = 0d;
	double dTotalRegOtAmt = 0d;
	double dTotalRestOtHr = 0d;
	double dTotalRestOtAmt = 0d;
	double dTotalNightHrs = 0d;
	double dTotalNightDiff = 0d;
	double dTotalOver = 0d;
	
	double dTotalHonorarium = 0d;
	double dTotalHonorDed = 0d;
	double dTotalLateUT = 0d;
	double dTotalCola = 0d;
	double dTotalSubsist = 0d;	
	double dTotalGross = 0d;	
	double dTotalSSS = 0d;
	double dTotalPhealth = 0d;
	double dTotalHdmf = 0d;			
	double dTotalPERAA = 0d;
	double dTotalTax = 0d;
	double dTotalCaEduc = 0d;
	double dTotalPharma = 0d;
	double dTotalHosp = 0d;
	double dTotalCoop = 0d;
	double dTotalOthers = 0d;
	double dTotalSSSLoan = 0d;
	double dTotalHdmfLoan = 0d;			
	double dTotalPERAALoan = 0d;
	double dTotalPhone = 0d;
	double dTotalOtherEarn = 0d;

	double dTotalTuition = 0d;	
	double dTotalDeductions = 0d;
	double dTotalNetPay = 0d;
	
	// grand Total
	double dGTotalBasic = 0d;
	double dGTotalAdjust = 0d;	
	double dGTotalMeal  = 0d;	
	double dGHoursOver = 0d;
	double dGTotalOverLoad = 0d;
			
	double dGTotalSalary = 0d;
	double dGTotalRegOtHr = 0d;
	double dGTotalRegOtAmt = 0d;
	double dGTotalRestOtHr = 0d;
	double dGTotalRestOtAmt = 0d;
	double dGTotalNightHrs = 0d;
	double dGTotalNightDiff = 0d;
	double dGTotalOver = 0d;
	
	double dGTotalHonorarium = 0d;
	double dGTotalHonorDed = 0d;
	double dGTotalLateUT = 0d;
	double dGTotalCola = 0d;
	double dGTotalSubsist = 0d;	
	double dGTotalGross = 0d;	
	double dGTotalSSS = 0d;
	double dGTotalPhealth = 0d;
	double dGTotalHdmf = 0d;			
	double dGTotalPERAA = 0d;
	double dGTotalTax = 0d;
	double dGTotalCaEduc = 0d;
	double dGTotalPharma = 0d;
	double dGTotalHosp = 0d;
	double dGTotalCoop = 0d;
	double dGTotalOthers = 0d;
	double dGTotalSSSLoan = 0d;
	double dGTotalHdmfLoan = 0d;			
	double dGTotalPERAALoan = 0d;
	double dGTotalPhone = 0d;
	double dGTotalOtherEarn = 0d;

	double dGTotalTuition = 0d;	
	double dGTotalDeductions = 0d;
	double dGTotalNetPay = 0d;
	// END GRAND TOTAL variables
	double dLineTotal = 0d;
	int iMainTemp = 0;
		
	vRetResult = RptPayExtn.generatePayrollRegister(dbOP);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");		
	 for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) + "-" + (String)vSalaryPeriod.elementAt(i + 7);
				strPayEnd = (String)vSalaryPeriod.elementAt(i + 7);
				break;
			}
	 }
	if (vRetResult != null) {
		
		int iPage = 1; 
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

		int iNumRec = 0;
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(iFieldCount*iMaxRecPerPage);			
	  if((vRetResult.size() % (iFieldCount*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
		 iMainTemp = iNumRec;
		 dTotalBasic = 0d;
		 dTotalAdjust = 0d;	
		 dTotalMeal  = 0d;	
		 dHoursOver = 0d;
		 dTotalOverLoad = 0d;
					
		 dTotalSalary = 0d;
		 dTotalRegOtHr = 0d;
		 dTotalRegOtAmt = 0d;
		 dTotalRestOtHr = 0d;
		 dTotalRestOtAmt = 0d;
		 dTotalNightHrs = 0d;
		 dTotalNightDiff = 0d;
		 dTotalOver = 0d;
		 
		 dTotalSSSLoan = 0d;
		 dTotalHdmfLoan = 0d;
		 dTotalPERAALoan = 0d;
		 dTotalPhone = 0d;		 
			
		 dTotalHonorarium = 0d;
		 dTotalHonorDed = 0d;
		 dTotalLateUT = 0d;
		 dTotalCola = 0d;
		 dTotalSubsist = 0d;	
		 dTotalGross = 0d;	
		 dTotalSSS = 0d;
		 dTotalPhealth = 0d;
		 dTotalHdmf = 0d;			
		 dTotalPERAA = 0d;
		 dTotalTax = 0d;
		 dTotalCaEduc = 0d;
		 dTotalPharma = 0d;
		 dTotalHosp = 0d;
		 dTotalCoop = 0d;

		 dTotalTuition = 0d;	
		 dTotalDeductions = 0d;
		 dTotalNetPay = 0d;
%>
<body onLoad="javascript:window.print();">
<form name="form_">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
		</tr>
		<tr>
			<td>PAYROLL - <%=strPayEnd%></td>
		</tr>
		<tr>
			<td>Days worked cut- off: <%=strPayrollPeriod%></td>
		</tr>
		<tr>
			<td height="19" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="7%" height="35" align="center"class="thinborderBOTTOMLEFT">Acct. No </td>
      <td width="16%"  align="center" class="thinborderBOTTOMLEFT">NAME 
          OF EMPLOYEE </td>
			<%
				if (WI.fillTextValue("salary_base").equals("1")){
					strTemp = "RATE PER DAY";
					strTemp2 = "DAYS WORKED";
				}else if (WI.fillTextValue("salary_base").equals("2")){
					strTemp = "RATE PER HOUR";
					strTemp2 = "HOURS WORKED";
				}else{
					strTemp = "&nbsp;";
					strTemp2 = "&nbsp;";
				}
			%>					
      <td width="5%" align="center" class="thinborderBOTTOMLEFT"><%=strTemp%></td> 
      <td width="4%" height="33" align="center" class="thinborderBOTTOMLEFT"><%=strTemp2%></td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">BASIC SALARY </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">ADJ. </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">TRANSPO &amp;/OR MEAL ALLOW. </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">rate/hr<br>
      overload</td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT"># of hours of o/l </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">amount of o/l </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">Regular OT <br>
      (hours)</td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">Regular OT <br>
      (amount)</td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">Rest Day  OT <br>
      (hours)</td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">Rest Day  OT <br>
      (amount)</td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">Night Diff.<br>
      (hours)      </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">Night Diff. (Amount).      </td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFTRIGHT">OVERLOAD / OVERTIME </td>
    </tr>
    <% 
		for(iCount = 1;iMainTemp < vRetResult.size();iMainTemp += iFieldCount, ++iCount){
	  dLineTotal = 0d;
	  dBasic = 0d;
		dDaysWorked = 0d;
		dLineOver = 0d;
		
		i = iMainTemp;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
	  %>
    <tr>
      <%
				// Account number
				strTemp = (String)vRetResult.elementAt(i + iStart + 1); 			
			%>			
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td> 
      <td height="18" class="thinborderBOTTOMLEFT"><strong><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),
							(String)vRetResult.elementAt(i+6), 4)%></strong></td>
      <%
				//rate per day
				strTemp2 = (String)vRetResult.elementAt(i + iStart + 11); 			
				if(strTemp2.equals("1")){
					strTemp = (String)vRetResult.elementAt(i + iStart + 2); 			
				}else if(strTemp2.equals("2")){
					strTemp = (String)vRetResult.elementAt(i + iStart + 10); 			
				}else{
					strTemp = "";
				}
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dLineTotal = dTemp;				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
      <%
				// days worked
				strTemp2 = (String)vRetResult.elementAt(i + iStart + 11); 			
				if(strTemp2.equals("1")){
					strTemp = (String)vRetResult.elementAt(i + 16);
				}else if(strTemp2.equals("2")){
					strTemp = (String)vRetResult.elementAt(i + 21); 			
				}	else{
					strTemp = "";
				}			
				dDaysWorked= Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				if(dDaysWorked== 0d)
					strTemp = "0.00";
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// basic salary
				dLineTotal = dDaysWorked * dTemp;
				dTotalBasic += dLineTotal;
			%>		     
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%></td>
      <%
				// adjustment amount
				strTemp = (String)vRetResult.elementAt(i + 7); 	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalAdjust += dTemp;
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				if(dTemp == 0d)
					strTemp = "0.00";
			%>		     
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// meal and transpo allowance
				strTemp = (String)vRetResult.elementAt(i + iStart + 9);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalMeal += dTemp;
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	     
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// overload rate per hour
				strTemp = (String)vRetResult.elementAt(i + iStart + 3);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));																
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	  
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// overload units
				strTemp = (String)vRetResult.elementAt(i + 19);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	  
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
			<%
				// overload amount
				strTemp = (String)vRetResult.elementAt(i + 20);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dLineOver += dTemp;
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalOverLoad += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	     
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// regular OT Hours
				strTemp = (String)vRetResult.elementAt(i + iStart + 5);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalRegOtHr += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>   
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%>&nbsp;</td>
      <%
				// regular OT amount
				strTemp = (String)vRetResult.elementAt(i + iStart + 6);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineOver += dTemp;
				dTotalRegOtAmt += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// rest day OT hours
				strTemp = (String)vRetResult.elementAt(i + iStart + 7);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalRestOtHr += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// rest day OT amount
				strTemp = (String)vRetResult.elementAt(i + iStart + 8);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dLineOver += dTemp;
				dTotalRestOtAmt += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  	    
			<td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// Number of hours night differential
				strTemp = (String)vRetResult.elementAt(i + iStart + 21);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dTotalNightHrs += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// night differential amount
				strTemp = (String)vRetResult.elementAt(i + 8);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalNightDiff += dTemp;
				//dLineOver += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>      
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
			<%
				dTotalOver +=dLineOver;
			%>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dLineOver,true)%></td>
    </tr>
    <%}//end for loop%>
		<%		
			dGTotalBasic += dTotalBasic;
			dGTotalAdjust += dTotalAdjust;
			dGTotalMeal += dTotalMeal;
			dGHoursOver += dHoursOver;
			dGTotalOverLoad += dTotalOverLoad;
			dGTotalRegOtHr += dTotalRegOtHr;
			dGTotalRegOtAmt += dTotalRegOtAmt;
			dGTotalRestOtHr += dTotalRestOtHr;
			dGTotalRestOtAmt += dTotalRestOtAmt;
			dGTotalNightHrs += dTotalNightHrs;
			dGTotalNightDiff += dTotalNightDiff;
			dGTotalOver += dTotalOver;
		%>
		<tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td> 
      <td height="18" align="right" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL :   </strong></font></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalBasic,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalAdjust,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalMeal,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dHoursOver,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOverLoad,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalRegOtHr,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalRegOtAmt,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalRestOtHr,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalRestOtAmt,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalNightHrs,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalNightDiff ,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dTotalOver,true)%></td>
    </tr>		
		<%if(iMainTemp == vRetResult.size()){%>
    <tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td height="18" align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td> 
      <td height="18" align="right" class="thinborderBOTTOMLEFT"><font size="1"><strong>GRAND TOTAL :   </strong></font></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalBasic,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalAdjust,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalMeal,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGHoursOver,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalOverLoad,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalRegOtHr,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalRegOtAmt,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalRestOtHr,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalRestOtAmt,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalNightHrs,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalNightDiff ,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dGTotalOver,true)%></td>
    </tr>
		<%}%>
  </table>  
	<%if(iMainTemp == vRetResult.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
	  </tr>
	</table>	
	<%}%>
	  <%if (bolPageBreak || iMainTemp == vRetResult.size()){%>
  <DIV style="page-break-before:always"></DIV>
  <% }//page break ony if it is not last page.%> 
	<%iMainTemp = iNumRec;%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
    </tr>
    <tr>
      <td>PAYROLL - <%=strPayEnd%></td>
    </tr>
    <tr>
      <td>Days worked cut- off: <%=strPayrollPeriod%></td>
    </tr>
    <tr>
      <td height="19" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="7%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">Acct. No </td>
      <td width="16%" height="33" rowspan="2" align="center" class="thinborderBOTTOMLEFT">NAME 
          OF EMPLOYEE </td>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">RLE &amp;/or Honorarium </td> 
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">OTHERS</td>
      <td height="15" colspan="2" align="center" class="thinborderBOTTOMLEFT">DEDUCTIONS</td>
      <td width="6%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">GROSS EARNINGS. </td>
      <td colspan="4" align="center" class="thinborderBOTTOMLEFT"> C O N T R I B U T I O N S </td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">WITHTAX</td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">SSS LOAN </td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">PAG-IBIG LOAN </td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">PERAA LOAN </td>
      <td width="5%" rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT">CA/EDUC LOAN </td>
    </tr>
    <tr>
      <td width="6%" height="20" align="center" class="thinborderBOTTOMLEFT">RLE &amp;/or Honorarium </td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">TARDINESS/<br>
      UNDERTIME</td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">SSS PREM </td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">PHILHEALTH</td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">HDMF PREM </td>
			<td width="6%" align="center" class="thinborderBOTTOMLEFT">PERAA</td>
    </tr>
	  <% 
		for(iCount = 1;iMainTemp < vRetResult.size(); iMainTemp += iFieldCount, ++iCount){
	  dLineTotal = 0d;
	  dBasic = 0d;
		dDaysWorked = 0d;
		dLineOver = 0d;		
		
		i = iMainTemp;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
    <tr>
      <%
				// Account number
				strTemp = (String)vRetResult.elementAt(i + iStart + 1); 			
			%>			
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td> 
      <td height="18" class="thinborderBOTTOMLEFT"><strong><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),
							(String)vRetResult.elementAt(i+6), 4)%></strong></td>
      <%
				//honorarium
				strTemp = (String)vRetResult.elementAt(i + 9); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				strTemp = CommonUtil.formatFloat(dTemp, true);
				dTotalHonorarium +=dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
      <%
				// Other Earnings 
				strTemp = (String)vRetResult.elementAt(i + iStart + 26); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				strTemp = CommonUtil.formatFloat(dTemp, true);
				dTotalOtherEarn += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
      <%
				strTemp = "0.00";
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// tardiness 
				strTemp = (String)vRetResult.elementAt(i + 10); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dTotalLateUT += dTemp;			
				if(dTemp == 0d)
					strTemp = "0.00";
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%></td>
      <%
				// Gross Earnings
				strTemp = (String)vRetResult.elementAt(i + iStart + 19);
				strTemp = ConversionTable.replaceString(strTemp,",",""); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp ,true);
				dTotalGross += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>		     
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// sss contribution
				strTemp = (String)vRetResult.elementAt(i + 11);			
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalSSS += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	     
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// philhealth
				strTemp = (String)vRetResult.elementAt(i + 12);				
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalPhealth += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	  
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// pag ibig
				strTemp = (String)vRetResult.elementAt(i +13);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dTotalHdmf += dTemp;
				
				strTemp = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	  
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
			<%
				// PERAA
				strTemp = (String)vRetResult.elementAt(i + 14);	
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalPERAA += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>	     
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// tax deduction
				strTemp = (String)vRetResult.elementAt(i + 15);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				strTemp = CommonUtil.formatFloat(strTemp,true);
				dTotalTax += dTemp;				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>   
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// SSS loan
				strTemp = (String)vRetResult.elementAt(i + iStart + 22);  	
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalSSSLoan += dTemp;				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>				
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// pag ibig loan
				strTemp = (String)vRetResult.elementAt(i + iStart + 23);  	
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalHdmfLoan += dTemp;				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>				
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// PERAA loan
				strTemp = (String)vRetResult.elementAt(i + iStart + 24);  	
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalPERAALoan += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>				
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// educational loans
				strTemp = (String)vRetResult.elementAt(i + iStart + 12);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalCaEduc += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				dTotalOver +=dLineOver;
			%>
    </tr>
    <%}//end for loop%>
		<%
			dGTotalHonorarium += dTotalHonorarium;
			dGTotalOtherEarn += dTotalOtherEarn;
			dGTotalHonorDed += dTotalHonorDed;
			dGTotalLateUT += dTotalLateUT;
			dGTotalGross += dTotalGross;
			dGTotalSSS += dTotalSSS;
			dGTotalPhealth += dTotalPhealth;
			dGTotalHdmf += dTotalHdmf;
			dGTotalPERAA += dTotalPERAA;
			dGTotalTax += dTotalTax;
			dGTotalSSSLoan += dTotalSSSLoan;
			dGTotalHdmfLoan += dTotalHdmfLoan;
			dGTotalPERAALoan += dTotalPERAALoan;
			dGTotalCaEduc += dTotalCaEduc;
		%>
		<tr>
      <td height="18" colspan="2" align="right" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL :   </strong></font></td> 
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHonorarium,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOtherEarn,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHonorDed,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalLateUT,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalGross,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalSSS,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPhealth,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHdmf,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPERAA,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalTax,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalSSSLoan,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHdmfLoan,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPERAALoan,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dTotalCaEduc,true)%></td>
    </tr>
		<%if(iMainTemp == vRetResult.size()){%>
    <tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td height="18" align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="right" class="thinborderBOTTOMLEFT"><font size="1"><strong> GRAND TOTAL :   </strong></font></td> 
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalHonorarium,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalOtherEarn,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalHonorDed,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalLateUT,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalGross,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalSSS,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalPhealth,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalHdmf,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalPERAA,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalTax,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalSSSLoan,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalHdmfLoan,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalPERAALoan,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dGTotalCaEduc,true)%></td>
    </tr>
		<%}%>
  </table>	
	<%if(iMainTemp == vRetResult.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="56%">&nbsp;</td>
			<td width="24%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Prepared by: </td>
			<td>Verified by: </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
	</table>	
	<%}%>
	  <%if (bolPageBreak || iMainTemp == vRetResult.size()){%>
  <DIV style="page-break-before:always"></DIV>
  <% }//page break ony if it is not last page.%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
    </tr>
    <tr>
      <td>PAYROLL - <%=strPayEnd%></td>
    </tr>
    <tr>
      <td>Days worked cut- off: <%=strPayrollPeriod%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="10"class="thinborderBOTTOM">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
    <tr>
      <td width="7%" height="35" align="center"class="thinborderBOTTOMLEFT">Acct. No </td>
      <td width="16%"  align="center" class="thinborderBOTTOMLEFT">NAME 
          OF EMPLOYEE </td>
      <td width="8%" align="center" class="thinborderBOTTOMLEFT">PHARMACY</td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT">TELEPHONE  BILL </td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">OTHERS</td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">HOSP BILL </td>
      <td width="5%" align="center" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFTRIGHT">COOP</span></td>
      <td width="6%" align="center" class="thinborderBOTTOMLEFT">TUITION FEE </td>
      <td width="9%" align="center" class="thinborderBOTTOMLEFT">TOTAL DEDUCTIONS </td>
      <td width="7%" align="center" class="thinborderBOTTOMLEFTRIGHT">NET PAY </td>
      <td width="25%" align="center">&nbsp;</td>
    </tr>
    <% 
		for(iCount = 1;iNumRec < vRetResult.size();iNumRec += iFieldCount, ++iCount){
	  dLineTotal = 0d;
	  dBasic = 0d;
		dDaysWorked = 0d;
		dLineOver = 0d;
		
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
	  %>
    <tr>
      <%
				// Account number
				strTemp = (String)vRetResult.elementAt(i + iStart + 1); 			
			%>			
      <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td> 
      <td height="18" class="thinborderBOTTOMLEFT"><strong><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),
							(String)vRetResult.elementAt(i+6), 4)%></strong></td>
      <%
				// pharmacy 
				strTemp = (String)vRetResult.elementAt(i + iStart + 13);  	
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalPharma += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  							
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// Telephone bill
				strTemp = (String)vRetResult.elementAt(i + iStart + 25); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));			
				dTotalPhone += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  				
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// Other Deductions
				strTemp = (String)vRetResult.elementAt(i + iStart + 17);  	
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dTotalOthers += dTemp;
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// hospital bill
				strTemp = (String)vRetResult.elementAt(i + iStart + 14);  	
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
			  dTotalHosp += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>  			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// COOP
				strTemp = (String)vRetResult.elementAt(i + iStart + 15);  	
				//strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));												
				dTotalCoop += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>			
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// tuition fee
				strTemp = (String)vRetResult.elementAt(i + iStart + 16); 			
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
				dTotalTuition += dTemp;
				
				if(dTemp == 0d)
					strTemp = "0.00";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
      <%
				// total deductions				 
				strTemp = (String)vRetResult.elementAt(i + iStart + 18);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dTotalDeductions += dTemp;			
			%>      
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"0.00")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i + iStart + 20); 
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));	
				dTotalNetPay += dTemp;
			%>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(strTemp,true)%></td>
      <td align="right">&nbsp;</td>
    </tr>
    <%}//end for loop%>
		<%
		dGTotalPharma += dTotalPharma;
		dGTotalPhone += dTotalPhone;
		dGTotalOthers += dTotalOthers;
		dGTotalHosp += dTotalHosp;
		dGTotalCoop += dTotalCoop;
		dGTotalTuition += dTotalTuition;
		dGTotalDeductions += dTotalDeductions; 
		dGTotalNetPay += dTotalNetPay;
		%>
		<tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td> 
      <td height="18" align="right" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL :   </strong></font></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPharma,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalPhone,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalOthers,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalHosp,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dTotalCoop ,true)%></span></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalTuition,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dTotalDeductions ,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dTotalNetPay,true)%></td>
      <td align="right">&nbsp;</td>
    </tr>
		<%if(iMainTemp == vRetResult.size()){%>
    <tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td height="18" align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr>
      <td class="thinborderBOTTOMLEFT">&nbsp;</td> 
      <td height="18" align="right" class="thinborderBOTTOMLEFT"><font size="1"><strong>GRAND TOTAL :   </strong></font></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalPharma,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalPhone,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalOthers,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalHosp,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalCoop ,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalTuition,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dGTotalDeductions ,true)%></td>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dGTotalNetPay,true)%></td>
      <td align="right">&nbsp;</td>
    </tr>
		<%}%>
  </table>	
	<%if(iMainTemp == vRetResult.size()){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="51%">&nbsp;</td>
			<td width="24%">&nbsp;</td>
			<td width="25%">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>VP for Administration </td>
			<td>&nbsp;</td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
	</table>	
	<%}%>
  <%if (iNumRec < vRetResult.size()){%>
  <DIV style="page-break-before:always"></DIV>
  <% }//page break ony if it is not last page.
	  } //end for (iNumRec < vRetResult.size()
  } //end end upper most if (vRetResult !=null)%>  	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>