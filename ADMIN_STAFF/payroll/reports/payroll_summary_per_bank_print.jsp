<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

</script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./payroll_summary_per_bank_print.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME,
								enrollment.CurriculumCollege" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;
	int iCols = 0;
	double dPeriodRate   = 0d;	
	double dCollegeTotal = 0d;
	double dGrossPay     = 0d;
	double dHonorarium   = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetpay       = 0d;
	double dAbsenceAmt   = 0d;
	double dTempSalary   = 0d;
	double dTemp = 0d;

//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_summary_per_bank_print.jsp");
								
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
														"payroll_summary_per_bank_print.jsp");
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
	
	Vector vColleges = null;
	CurriculumCollege CC = new CurriculumCollege();	
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	Vector vFacultyPay = null;
	Vector vFacAbsence = null;
		
	Vector vOtherSummary = null;
	Vector vDeductions      = null;
	Vector vEarnings        = null;
	
if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
	vColleges = CC.viewall(dbOP);

	vRetResult = RptPay.operateDeptSummary(dbOP);
	if(vRetResult == null){
		strErrMsg = RptPay.getErrMsg();
	}
	if(vRetResult != null && vRetResult.size() > 2){
		vOtherSummary = (Vector)vRetResult.elementAt(0);
 		if(vOtherSummary != null && vOtherSummary.size() > 0)
			vDeductions = (Vector)vOtherSummary.elementAt(1);			
 	}
		
	vFacultyPay  = RptPay.getFacultyPaySummary(dbOP);
//	System.out.println(vFacultyPay);
	vFacAbsence = RptPay.getFacultyAbsentSummary(dbOP);
//	System.out.println(vFacAbsence);
}
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if (vRetResult!= null && vRetResult.size() > 2){%>
    <tr> 
      <td height="10" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
    </tr>
    <tr> 
      <% strTemp = "";
	  if (vRetResult!= null && vRetResult.size() > 2){	  	
		strTemp = (String)vRetResult.elementAt(1);			
		}
		%>
      <td width="7" height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="center"><font size="1"><strong><%=WI.getStrValue(strTemp," ")%></strong></font></div></td>
      <td width="99">&nbsp;</td>
      <%
	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
          }
		 }
		%>
      <td width="392" height="10"><div align="right"><strong><font color="#000000" size="1">PAYROLL 
          DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong><font size="1">&nbsp;&nbsp;</font>&nbsp;&nbsp;</div></td>
    </tr>
    <%}// display if (vRetResult!= null && vRetResult.size() > 2 %>
  </table>
   <%if (vRetResult!= null && vRetResult.size() > 2){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr>
       <td height="165" colspan="6" valign="top" class="thinborderTOPLEFT"><div align="left">
           <table width="100%" border="0" cellpadding="0" cellspacing="0">
             <tr>
               <td height="18" valign="top">&nbsp;</td>
               <td><div align="center"><strong><font size="1">Period</font></strong></div></td>
               <td><div align="center"><strong><font size="1">ABSENT</font></strong></div></td>
               <td>&nbsp;</td>
             </tr>
             <tr>
               <td height="18" class="thinborderBOTTOM"><font size="1">&nbsp;</font></td>
               <td class="thinborderBOTTOM"><div align="center"><font size="1"><strong>Rate</strong></font></div></td>
               <td class="thinborderBOTTOM"><div align="center"><font size="1"><strong>AMT.</strong></font></div></td>
               <td class="thinborderBOTTOM"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
             </tr>
             <tr>
               <td height="15" ><strong><font size="1">Admin</font></strong></td>
               <%
			 if (vRetResult != null && vRetResult.size() > 2){
			   for(int j = 2;j < vRetResult.size(); j+=5){
			  // for Employee computation
			     if (  (String)vRetResult.elementAt(j+2) == null || 
				 	  ((String)vRetResult.elementAt(j+2)).equals("0")){
					strTemp = (String) vRetResult.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dTempSalary += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop
			 }// end if vRetResult != null
			  // end of employee computation
			  
			 // for faculty computation
			 if (vFacultyPay != null && vFacultyPay.size() > 0){
			   for(int j = 0;j < vFacultyPay.size(); j+=2){
			     if (((String)vFacultyPay.elementAt(j+1)).equals("0")){
					strTemp = (String) vFacultyPay.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dTempSalary += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop			 
			 }			  
			  strTemp = Double.toString(dTempSalary);
			  %>
               <td height="15" ><div align="right"><font size="1"><%=WI.getStrValue(strTemp," ")%><strong>&nbsp;</strong></font></div></td>
               <%
			 if (vRetResult != null && vRetResult.size() > 2){
			   for(int j = 2;j < vRetResult.size(); j+=5){
			   // computation for employee with dtr... AWOL
			     if ( (String)vRetResult.elementAt(j+2) == null || 
				 	 ((String)vRetResult.elementAt(j+2)).equals("0")){
					strTemp = (String) vRetResult.elementAt(j+1);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dAbsenceAmt += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop
			 }// end if vRetResult != null
			  // end of employee computation
			  
			 // for faculty computation
			// System.out.println("index main " + (String) vColleges.elementAt(i));
			 if (vFacAbsence != null && vFacAbsence.size() > 0){
			   for(int j = 0;j < vFacAbsence.size(); j+=3){
			   //System.out.println("index -------" + (String)vFacAbsence.elementAt(j));
			   	strTemp = WI.getStrValue((String)vFacAbsence.elementAt(j));
			     if ((strTemp).equals("0")){
				 //System.out.println("equal");
					strTemp = (String) vFacAbsence.elementAt(j+1);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dAbsenceAmt += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop			 
			 }			  
			  strTemp = Double.toString(dAbsenceAmt);
			  %>
               <td height="15" ><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font>&nbsp;</div></td>
               <%
			  	dCollegeTotal = dTempSalary - dAbsenceAmt;
				dGrossPay += dCollegeTotal;				
			  %>
               <td height="15" ><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dCollegeTotal,true),"")%>&nbsp;</font> </div></td>
             </tr>
             <%if (vColleges != null && vColleges.size() > 0){%>
             <%for(i = 0;i<vColleges.size();i+=4){
				dTempSalary = 0d;
				dAbsenceAmt = 0d;			  
				strTemp = (String) vColleges.elementAt(i+1);				
			%>
             <tr>
               <td width="22%" height="15" ><strong>&nbsp;<font size="1"><%=WI.getStrValue(strTemp,"")%></font></strong></td>
               <%
			 if (vRetResult != null && vRetResult.size() > 2){
			   for(int j = 2;j < vRetResult.size(); j+=5){
			  // for Employee computation
			     if (((String) vColleges.elementAt(i)).equals((String)vRetResult.elementAt(j+2))){
					strTemp = (String)vRetResult.elementAt(j+4);
					strTemp = ConversionTable.replaceString(strTemp,",","");
					dHonorarium += Double.parseDouble(strTemp);

					strTemp = (String) vRetResult.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dTempSalary += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop
			 }// end if vRetResult != null
			  // end of employee computation
			  
			 // for faculty computation
			 if (vFacultyPay != null && vFacultyPay.size() > 0){
			   for(int j = 0;j < vFacultyPay.size(); j+=2){
			     if (((String) vColleges.elementAt(i)).equals((String)vFacultyPay.elementAt(j+1))){
					strTemp = (String) vFacultyPay.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dTempSalary += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop			 
			 }			  
			  strTemp = Double.toString(dTempSalary);
			  %>
               <td width="31%" height="15" ><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"")%></font>&nbsp;</div></td>
               <%
			 if (vRetResult != null && vRetResult.size() > 2){
			   for(int j = 2;j < vRetResult.size(); j+=5){
			   // computation for employee with dtr... AWOL
			     if (((String) vColleges.elementAt(i)).equals((String)vRetResult.elementAt(j+2))){
					strTemp = (String) vRetResult.elementAt(j+1);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dAbsenceAmt += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop
			 }// end if vRetResult != null
			  // end of employee computation
			  
			 // for faculty computation
			// System.out.println("index main " + (String) vColleges.elementAt(i));
			 if (vFacAbsence != null && vFacAbsence.size() > 0){
			   for(int j = 0;j < vFacAbsence.size(); j+=3){
			   //System.out.println("index -------" + (String)vFacAbsence.elementAt(j));
			     if (((String) vColleges.elementAt(i)).equals((String)vFacAbsence.elementAt(j))){
				 //System.out.println("equal");
					strTemp = (String) vFacAbsence.elementAt(j+1);
					strTemp = ConversionTable.replaceString(strTemp,",","");			
					dAbsenceAmt += Double.parseDouble(strTemp);
					break;
				 }// end if equal
			   }// end for loop			 
			 }			  
			  strTemp = Double.toString(dAbsenceAmt);
			  %>
               <td width="22%" height="15" ><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%></font>&nbsp; </div></td>
               <%
			  	dCollegeTotal = dTempSalary - dAbsenceAmt;
				dGrossPay += dCollegeTotal;				
			  %>
               <td width="25%" height="15" ><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dCollegeTotal,true),"")%></font>&nbsp; </div></td>
             </tr>
             <% }// end outer for loop
			}// end if vColleges != null && ... vRetResult !- null
			%>
             <tr>
               <td width="22%" height="15" ><strong><font size="1">&nbsp;Hon.</font></strong></td>
               <%
			  	dGrossPay += dHonorarium;
			  %>
               <td width="31%" ><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dHonorarium,true),"")%></font><font size="1">&nbsp;</font></div></td>
               <td width="22%" >&nbsp;</td>
               <td width="25%" >&nbsp;</td>
             </tr>
           </table>
       </div>
           <div align="right"><font size="1">&nbsp;</font></div></td>
       <td width="34%" valign="top" class="thinborderTOPLEFT"><table width="100%" height="55" border="0" cellpadding="0" cellspacing="0">
           <tr>
             <td width="38%" height="18"><div align="center"><strong><font size="1">Total</font></strong></div></td>
             <td width="31%" height="18"><div align="center"></div></td>
             <td width="31%" height="18">&nbsp;</td>
           </tr>
           <tr>
             <td height="17" class="thinborderBOTTOM"><div align="center"><strong><font size="1">Earnings</font></strong></div></td>
             <td height="17"class="thinborderBOTTOM"><div align="center"><strong><font size="1">Prev. 
               Pay</font></strong></div></td>
             <td height="17" class="thinborderBOTTOM"><div align="center"><strong><font size="1">COLA</font></strong></div></td>
           </tr>
           <tr>
             <td height="18"><div align="center"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossPay,true),"")%></font> </div></td>
             <% strTemp = "";
						if(vRetResult != null && vRetResult.size() > 2){
							if(vOtherSummary != null && vOtherSummary .size() > 0 ){
								strTemp = (String)vOtherSummary.elementAt(2);
								dGrossPay  += Double.parseDouble(strTemp);					
							}
						 }
						 %>
             <td><div align="center"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%></font></div></td>
             <%strTemp = "";
	     if(vRetResult != null && vRetResult.size() > 2){	   
			if(vOtherSummary != null && vOtherSummary .size() > 0 ){
			  strTemp = (String)vOtherSummary.elementAt(3);
				dGrossPay  += Double.parseDouble(strTemp);
			}
		 }
	   %>
             <td><div align="center"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%></font></div></td>
           </tr>
       </table></td>
       <td colspan="2" valign="top" class="thinborderTOPLEFTRIGHT"><table width="100%" border="0" cellpadding="0" cellspacing="0">
           <tr>
             <td height="18"><font size="1"><strong>DEDUCTION</strong></font></td>
             <td>&nbsp;</td>
           </tr>
           <tr>
             <td height="18" class="thinborderBOTTOM"><strong><font size="1">TYPE</font></strong></td>
             <td class="thinborderBOTTOM"><div align="right"><strong><font size="1">AMT.&nbsp;&nbsp;</font></strong></div></td>
           </tr>
           <tr>
             <td width="57%" height="18"><font size="1">&nbsp;PAG-IBIG</font> </td>
             <%strTemp = "";
			 if(vRetResult != null && vRetResult.size() > 2){
				if(vOtherSummary != null && vOtherSummary .size() > 0 ){
					strTemp = (String)vOtherSummary.elementAt(6);
					dTotalDeduction += Double.parseDouble(strTemp);
				}
			 }
		   %>
             <td width="43%"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</font></div></td>
           </tr>
           <tr>
             <td height="18"><font size="1">&nbsp;SSS</font></td>
             <% strTemp = "";
			 if(vRetResult != null && vRetResult.size() > 2){
				if(vOtherSummary != null && vOtherSummary .size() > 0 ){
					strTemp = (String)vOtherSummary.elementAt(4);
					dTotalDeduction += Double.parseDouble(strTemp);			
				}
			 }
		   %>
             <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</font></div></td>
           </tr>
           <tr>
             <td height="18"><font size="1">&nbsp;PhilHealth</font></td>
             <% strTemp = "";
			 if(vRetResult != null && vRetResult.size() > 2){
				if(vOtherSummary != null && vOtherSummary .size() > 0 ){
					strTemp = (String)vOtherSummary.elementAt(5);
					dTotalDeduction += Double.parseDouble(strTemp);			
				}
			 }
		   %>
             <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</font></div></td>
           </tr>
           <tr>
             <td height="18"><font size="1">&nbsp;W/Holding Tax</font></td>
             <% strTemp = "";
			if(vRetResult != null && vRetResult.size() > 2){
				if(vOtherSummary != null && vOtherSummary .size() > 0 ){
					strTemp = (String)vOtherSummary.elementAt(7);
					dTotalDeduction += Double.parseDouble(strTemp);			
				}				
			 }
		   %>
             <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</font></div></td>
           </tr>
			<% 
 				for(iCols = 1;iCols < vDeductions.size(); iCols += 2){
					strTemp = (String)vDeductions.elementAt(iCols);			
			%>		
          <tr>
            <td height="18"><font size="1">&nbsp;<%=strTemp%></font></td>
			      <%
				strTemp = (String)vDeductions.elementAt(iCols+1);
				dTemp = Double.parseDouble(strTemp);
				dTotalDeduction += dTemp;
				if(dTemp == 0d)
					strTemp = "";									
				%>											
            <td align="right"><font size="1"><%=strTemp%>&nbsp;&nbsp;&nbsp;</font></td>
          </tr>
			<%}%>					
           <tr>
             <td height="18"><font size="1">&nbsp;Others</font></td>
             <% strTemp = "";
			if(vRetResult != null && vRetResult.size() > 2){
				if(vOtherSummary != null && vOtherSummary.size() > 0 ){
 					strTemp = (String)vOtherSummary.elementAt(9); // MISC_DEDUCTION
					dOtherDeduction += Double.parseDouble(strTemp);			
					//System.out.println("dOtherDeduction "  + dOtherDeduction);
							
					strTemp = (String)vOtherSummary.elementAt(10); // LATE_UNDER_AMT
					dOtherDeduction += Double.parseDouble(strTemp);			
					//System.out.println("dOtherDeduction "  + dOtherDeduction);
					
					strTemp = (String)vOtherSummary.elementAt(11); // LEAVE_DEDUCTION_AMT
					dOtherDeduction += Double.parseDouble(strTemp);
					//System.out.println("dOtherDeduction "  + dOtherDeduction);					
									
					dTotalDeduction += dOtherDeduction;
					//System.out.println("dTotalDeduction "  + dTotalDeduction);
					
				}
			 }
		   %>
             <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dOtherDeduction,true),"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
           </tr>
       </table></td>
     </tr>
     <tr>
       <td height="15" colspan="6" valign="top" class="thinborderLEFT">&nbsp;</td>
       <td valign="top" class="thinborderLEFT">&nbsp;</td>
       <td valign="top" class="thinborderLEFT">&nbsp;</td>
       <td valign="top" class="thinborderRIGHT">&nbsp;</td>
     </tr>
     <tr>
       <td height="26" colspan="6" valign="top" class="thinborderLEFT"><div align="right">GROSS 
         PAY :</div></td>
       <td valign="top" class="thinborderLEFT">&nbsp;&nbsp;&nbsp; <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dGrossPay,true),"")%></font> </td>
       <td width="14%" valign="top" class="thinborderLEFT"><div align="right"><font size="1">TOTAL 
         DEDUCTION: </font></div></td>
       <td width="13%" valign="top" class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
     </tr>
     <tr>
       <td height="26" colspan="6" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
       <td valign="top" class="thinborderBOTTOMLEFT"><div align="right"><font size="1">NET PAY:</font></div></td>
       <%
	  	dNetpay = dGrossPay - dTotalDeduction;
	  %>
       <td valign="top" class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dNetpay,true),"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
     </tr>
   </table>
   <%}// display if (vRetResult!= null && vRetResult.size() > 2%>
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
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