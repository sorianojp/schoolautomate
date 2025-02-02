<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME,
								payroll.OvertimeMgmt " %>
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
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTRIGHT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPRIGHT {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 10px;  
		}		
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_summary_per_office_print.jsp");
								
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
														"payroll_summary_per_office_print.jsp");
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
	OvertimeMgmt otMgmt = new OvertimeMgmt();
	String strSchCode = dbOP.getSchoolIndex();

	double dPeriodRate   = 0d;
	double dCollegeTotal = 0d;
	double dGrossSalary     = 0d;
	double dHonorarium   = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetpay       = 0d;
	double dTempSalary   = 0d;
	double dAbsenceAmt   = 0d;	
	double dTemp  = 0d;
	double dUnreleasedSalary = 0d;
	double dNetSalary  = 0d;
	double dOtherEarning  = 0d;
	
	Vector vRetResult = null;
	PayrollSheet RptPSheet = new PayrollSheet(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strDailyRate = null;
	String strHourlyRate = null;
	String strSlash = null;
	int i = 0;

	Vector vPayPerCollege = null;
	Vector vFacAbsences = null;	

	Vector vEarnings = null;
	Vector vDeductions = null;
	Vector vOTDetail = null;
	Vector vSalDetail = null;	
	Vector vRows = null;
	Vector vEarnCols = null;
	Vector vDedCols = null;	
	Vector vEarnDedCols = null;
	Vector vOTWithType = null;
	Vector vEmpOT = null;
	Vector vOTTypes = null;
	Vector vAdjTypes = null;
	
	int iCols = 0;
	int iEarnColCount = 0;
	int iDedColCount = 0;
	int iEarnDedCount = 0;
	int iColCounter = 0;
	int iMain = 0;
	int iIndex  = 0;
		
	int iFieldCount = 75;// number of fields in the vector..	
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");			
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		break;
	  }//end of if condition.		  
	 }//end of for loop.

	vRetResult = RptPSheet.getPSheetItems(dbOP);	
	if(vRetResult == null){
		strErrMsg = RptPSheet.getErrMsg();
	}
		
	if (vRetResult != null) {	
		int j = 0; int k = 0; int iCount = 0;int o = 0;
		int iMaxRecPerPage = 1; 
		int iNumRec = 0;//System.out.println(vRows);
		int iIncr    = 1;

		vRows = (Vector)vRetResult.elementAt(0);
		vEarnCols = (Vector)vRetResult.elementAt(1);
		vDedCols = (Vector)vRetResult.elementAt(2);			
		vEarnDedCols = (Vector)vRetResult.elementAt(3);	
		vEmpOT = (Vector)vRows.elementAt(i+65);
		
		if(WI.fillTextValue("hide_overtime").equals("1"))
			vOTTypes = otMgmt.getOTTypeUsedForPeriod(dbOP, request, true);
		else
			vOTTypes = otMgmt.operateOnOvertimeType(dbOP, request, 4, "1");
		
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
					
		iSearchResult = RptPSheet.getSearchCount();		

		for (;iNumRec < vRows.size();){	
%>

  <% 
	for(iCount = 1; iNumRec<vRows.size(); iNumRec+=iFieldCount,++iIncr, ++iCount){
		if(WI.fillTextValue("save_"+iIncr).length() == 0)
			continue;
	
		dOtherDeduction = 0d;
		dNetSalary = 0d;
		dGrossSalary = 0d;
		dTotalDeduction = 0d;
		dUnreleasedSalary = 0d;
			
		iMain = iNumRec;
		vEarnings = (Vector)vRows.elementAt(iMain+53);
		vDeductions = (Vector)vRows.elementAt(iMain+54);
		vSalDetail = (Vector)vRows.elementAt(iMain+55); 
		vOTDetail = (Vector)vRows.elementAt(iMain+56); 
		vFacAbsences = (Vector)vRows.elementAt(iMain+57); 
		vPayPerCollege = (Vector)vRows.elementAt(iMain+58); 			
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>  
	<%if(strSchCode.startsWith("TSUNEISHI")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr> 
				<td height="40" colspan="5" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong>
			<br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			,&nbsp;<%=SchoolInformation.getAddressLine2(dbOP,false,false)%></td>
			</tr>
	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
       <td colspan="4" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
         <tr>
           <td colspan="3"><strong>PAYSLIP </strong></td>
           <td width="33%">&nbsp;</td>
          </tr>
         <tr>
           <td width="8%">Period</td>
           <td width="45%">&nbsp;<font size="1"><%=WI.getStrValue(strPayrollPeriod,"&nbsp;")%></font></td>
           <td width="14%">Employee ID </td>
           <td><%=WI.getStrValue((String)vRows.elementAt(iMain+60))%></td>
          </tr>
         <tr>
           <td>Group</td>
					 <%
					 	if(vRows.elementAt(iMain+62) == null || vRows.elementAt(iMain+63) == null)
							strTemp = "";
						else
							strTemp = " - ";
					 %>
           <td>&nbsp;<%=WI.getStrValue((String)vRows.elementAt(iMain+62),"")%><%=strTemp%><%=WI.getStrValue((String)vRows.elementAt(iMain+63),"")%></td>
           <td>Name</td>
					<% strTemp = "";
						strTemp = WI.formatName((String)vRows.elementAt(iMain+4), (String)vRows.elementAt(iMain+5),
									(String)vRows.elementAt(iMain+6), 4);
						strTemp = strTemp.toUpperCase();
					%>					 
           <td><%=strTemp%></td>
          </tr>
         
       </table></td>
     </tr>
     
     
     <tr>
       <td valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
         
         <tr>
           <td width="51%" height="16" class="thinborderNONE"><strong>A. Basic</strong></td>
           <td width="49%" align="right" class="thinborderNONE">
              <%
								strTemp = (String)vRows.elementAt(iMain + 7);	
								dGrossSalary += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							%>
              <%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
         </tr>
         <%  
						strTemp = (String)vRows.elementAt(iMain + 26);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
					 %>
         <tr>
           <td height="16" class="thinborderNONE"><strong>B. Holiday</strong></td>
           <td align="right" class="thinborderNONE"> <font size="1"> <%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
         </tr>        
         <tr>
           <td height="16" class="thinborderNONE"><strong>C. Leave</strong></td>
           <td align="right" class="thinborderNONE"><div align="right"></div></td>
         </tr>
         <tr>
           <td height="16" class="thinborderNONE"><strong>D. Overtime</strong></td>
         <%
						strTemp = (String)vRows.elementAt(iMain+23);// total OT
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dGrossSalary += dTemp; 
				 %>
           <td align="right" class="thinborderNONE"> <font size="1"> <%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
         </tr>
				 <% 
					strTemp = (String)vRows.elementAt(iMain+24); // night differential
					dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
					dGrossSalary += dTemp; 
					if(dTemp > 0d){
						strTemp = "";
					%>
         <tr>
           <td class="thinborderNONE" height="16">Night Differential </td>
           <td align="right" class="thinborderNONE"><font size="1"> <%=WI.getStrValue(strTemp,"")%>&nbsp;</font></td>
         </tr>         
         <%}%>
				 <tr>
           <td height="16" colspan="2" class="thinborderNONE">
					<%if(vEmpOT != null && vEmpOT.size() > 0){%>
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="44%">&nbsp;</td>
            <td align="center" width="22%" ><font size="1">HRS</font></td>
            <td align="center" width="34%"><font size="1">Amount</font></td>
          </tr>
					<% for(i = 0; i < vEmpOT.size(); i+=3){%>
          <tr>
					<%
						 strTemp = null;
						 iIndex = vOTTypes.indexOf((Integer)vEmpOT.elementAt(i));
						 if(iIndex != -1){
							 strTemp = (String)vOTTypes.elementAt(iIndex+1);		
							 strTemp += "<br>"+ CommonUtil.formatFloat((String)vOTTypes.elementAt(iIndex+3),false);							 			 
						 }					
					%>
            <td height="20" class="thinborderNONE">&nbsp;<%=WI.getStrValue(strTemp)%></td>
					<%
						strTemp = (String)vEmpOT.elementAt(i+1);
					%>
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%></font></td>
						<%
						strTemp = (String)vEmpOT.elementAt(i+2);					
						%>						
            <td align="right"><font size="1"><%=WI.getStrValue(strTemp,"0")%>&nbsp;</font></td>
            </tr>
					<%}%>
        </table>
					<%}// end vEmpOT%>				
					</td>
          </tr>				 
       </table></td>
       <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
			 <tr>
				 <td  height="16" colspan="2" class="thinborderNONE"><strong>E. Allowances</strong></td>
				 <td align="right" class="thinborderNONE">&nbsp;</td>
			 </tr>
         <%
						if(vEarnings != null && vEarnings.size() > 1){
						dOtherEarning = 0d;
						for(iCols = 2;iCols <= iEarnColCount + 1; iCols ++){
 						%>
         <tr>
           <td width="6%"  height="16" class="thinborderNONE">&nbsp;</td>
					 <td width="46%" class="thinborderNONE"><%=(String)vEarnCols.elementAt(iCols)%></td>
					 <%
					strTemp = (String)vEarnings.elementAt(iCols);
					dTemp = Double.parseDouble(strTemp);
					if(dTemp == 0d)
						strTemp = "";								 
					 %>
           <td width="48%" align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"-")%>&nbsp;&nbsp;</td>
         </tr>
         <%}// END FOR LOOP
					}// END NULL CHECK%>         
         <tr>
           <td height="16" colspan="2" class="thinborderNONE"><strong>F. Other Income </strong></td>
           <%
							// addl pay amount
							strTemp = (String)vRows.elementAt(iMain+27); 
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;
							
							// adhoc allowances
							strTemp = (String)vRows.elementAt(iMain+28); 
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;
							
							// addl_resp_amt
							strTemp = (String)vRows.elementAt(iMain+29); 
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;								

							
							// substitute salary
							strTemp = (String)vRows.elementAt(iMain+38); 
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
							dGrossSalary += dTemp;								
							
							dGrossSalary += dOtherEarning;
						 %>
           <td class="thinborderNONE"><div align="right"><%=CommonUtil.formatFloat(dOtherEarning,true)%>&nbsp;&nbsp;</div></td>
         </tr>
				 <tr>
           <td height="16" colspan="2" class="thinborderNONE"><strong>G. Absences</strong></td>
           <% 			
 			// leave without pay			
				strTemp = (String)vRows.elementAt(iMain + 33); 	
				dAbsenceAmt = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// AWOL
				strTemp = (String)vRows.elementAt(iMain + 47);
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
			// faculty absences
				strTemp = (String)vRows.elementAt(iMain + 49); 
				dAbsenceAmt += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));							
				dGrossSalary -= dAbsenceAmt;
				if(dAbsenceAmt > 0)
					strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
				else
					strTemp = "-";			
		   %>
           <td class="thinborderNONE"><div align="right"><%=strTemp%>&nbsp;&nbsp;</div></td>
         </tr>				 
         
       </table></td>
       <td valign="top" class="thinborderNONE"><table width="100%" border="0" cellspacing="0" cellpadding="0">
           
           <tr>
             <td height="16" colspan="2" class="thinborderNONE"><strong>H. Tardiness/Undertime</strong></td>
             <% 			

 			// Late and undertime
				strTemp = (String)vRows.elementAt(iMain+48); 
				dAbsenceAmt = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

				dGrossSalary -= dAbsenceAmt;
				if(dAbsenceAmt > 0)
					strTemp = CommonUtil.formatFloat(dAbsenceAmt,true);
				else
					strTemp = "-";
		   %>						 
             <td align="right" class="thinborderNONE"><%=strTemp%>&nbsp;&nbsp;</td>
           </tr>
           <tr>
             <td height="16" colspan="2" class="thinborderNONE"><strong>I. Gov't. Deductions </strong></td>
             <td align="right" class="thinborderNONE">&nbsp;</td>
           </tr>
           <tr>
             <td width="5%" class="thinborderNONE">&nbsp;</td>
             <td width="62%" class="thinborderNONE" height="16">W. Tax</td>
             <td width="33%" align="right" class="thinborderNONE">
                <% 
								strTemp = (String)vRows.elementAt(iMain + 46);
								dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
								strTemp = CommonUtil.formatFloat(strTemp,true);
								dTotalDeduction += dTemp;
								if(dTemp == 0d)
									strTemp = "";
							 %>
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					<% 
						strTemp = (String)vRows.elementAt(iMain + 39);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dTotalDeduction += dTemp;
						strTemp = CommonUtil.formatFloat(strTemp,true);
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16"> SSS premium</td>
             <td align="right" class="thinborderNONE">
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
           <% 
						strTemp = (String)vRows.elementAt(iMain + 42);
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						strTemp = CommonUtil.formatFloat(strTemp,true);
						dTotalDeduction += dTemp;
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16"> GSIS premium</td>
             <td align="right" class="thinborderNONE">
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16">Phil. Health</td>
             <td align="right" class="thinborderNONE">
            <% 
							strTemp = (String)vRows.elementAt(iMain + 40);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dTotalDeduction += dTemp;
							strTemp = CommonUtil.formatFloat(strTemp,true);
							if(dTemp == 0d)
								strTemp = "";			
						 %>
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="16"> Pag-ibig Premium</td>
             <td align="right" class="thinborderNONE">
            <% 
							strTemp = (String)vRows.elementAt(iMain +41);
							dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
							dTotalDeduction += dTemp;
							strTemp = CommonUtil.formatFloat(strTemp,true);
							if(dTemp == 0d)
								strTemp = "";
						 %>
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
           <% 
						strTemp = (String)vRows.elementAt(iMain + 49); // Ret. Plan Fund
						dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));			
						dTotalDeduction += dTemp;
						strTemp = CommonUtil.formatFloat(strTemp,true);
						if(dTemp > 0d){
					 %>
           <tr>
             <td class="thinborderNONE">&nbsp;</td>
             <td class="thinborderNONE" height="18">Ret. Plan Fund</td>
             <td align="right" class="thinborderNONE">
                <%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;</td>
           </tr>
					 <%}%>
       </table></td>
       <td valign="top" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
         <tr>
           <td height="16" class="thinborderNONE"><strong>J. Other Deductions </strong></td>
           <td align="right" class="thinborderNONE">&nbsp;</td>
         </tr>
				<%			
				for(iCols = 1;iCols <= iDedColCount; iCols +=2){
					strTemp = (String)vDedCols.elementAt(iCols);
				%>
         <tr>
           <td width="57%" class="thinborderNONE" height="16">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
					 <%
						strTemp = (String)vDeductions.elementAt(iCols/2);
						dTemp = Double.parseDouble(strTemp);
 						if(dTemp == 0d)
							strTemp = "";					 
					 %>
           <td width="43%" align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
         </tr>
         <%}// end for loop %>
         <tr>
           <td class="thinborderNONE" height="16">Others</td>
           <% 

							strTemp = (String) vRows.elementAt(iMain+45);//MISC_DEDUCTION (Addl ded)
							dOtherDeduction += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));

							strTemp = CommonUtil.formatFloat(dOtherDeduction,2);
							dTotalDeduction += dOtherDeduction; 
							if(dOtherDeduction == 0d)
								strTemp = "";
						
						%>
           <td align="right" class="thinborderNONE"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
         </tr>
         <tr>
           <td height="16" class="thinborderNONE"><strong>K. Total Deductions </strong></td>
           <td align="right" class="thinborderNONE"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</td>
         </tr>
       </table></td>
     </tr>
     
     <tr>
       <td valign="top">&nbsp;</td>
       <td valign="top">&nbsp;</td>
       <td valign="bottom">
			 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
         <tr>
           <td width="54%" class="thinborderNONE">&nbsp;Gross Pay :</td>
           <td width="46%" align="right" class="thinborderNONE"><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dGrossSalary,true),"0")%>&nbsp;</strong></font></td>
          </tr>
         <tr>
           <td height="18" class="thinborderNONE">&nbsp;Net Pay :</td>
						<%
						dNetSalary += dGrossSalary - dTotalDeduction;
						%>						 
					 <td align="right" class="thinborderNONE"><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dNetSalary,true),"0")%>&nbsp;</strong></font></td>
         </tr>
       </table></td>
       <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
         <tr>
           <td width="50%" class="thinborderBOTTOM">&nbsp;</td>
         </tr>
         <tr>
           <td class="thinborderNONE">Employee Signature </td>
         </tr>
       </table></td>
     </tr>
     <tr>
       <td colspan="4" valign="top"><hr size="1"></td>
     </tr>
     
     <tr>
       <td width="25%" height="2" ></td>
       <td width="25%" ></td>
       <td width="25%" ></td>
       <td width="25%" ></td>
     </tr>
  </table>	
	<%}%>
  <%} // end for loop%>
  <%if (bolPageBreak){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRows.size()
} //end end upper most if (vRows !=null)%>  
	<input type="hidden" name="is_for_sheet" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>