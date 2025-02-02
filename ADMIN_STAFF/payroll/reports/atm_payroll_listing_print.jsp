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
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body bgcolor="#FFFFFF" onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME,
																payroll.PRRemittance" %>
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
	double dPageTotal = 0d;
	double dGrandTotal = 0d;
	int i = 0; 
	double dSalary = 0d;
	
	
	boolean bolIsUB = false;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	if(strSchCode.startsWith("UB"))
		bolIsUB = true;
	

	// added Sept 12, 2009.. multiple employer
	String strPayrollPeriodTo = null;
	
	String strEmployerIndex = WI.fillTextValue("employer_index");
	Vector vEmployerInfo = null;
	vEmployerInfo = PRRemit.operateOnEmployerProfile(dbOP, 3, strEmployerIndex);
	if (vEmployerInfo == null || vEmployerInfo.size() == 0) {
		strErrMsg = "Employer profile not found";
	}
	
	vRetResult = RptPay.searchEmpATMListing(dbOP);
	//System.out.println("vRetResult " +vRetResult);
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
				  strPayrollPeriodTo = (String)vSalaryPeriod.elementAt(i + 7);
				  break;
		   	}
		}

	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"1000000"));

	int iNumRec = 1;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()-1)/(9*iMaxRecPerPage);	
	if((vRetResult.size() % (9*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2">
			  <%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
  	      <%=strTemp%><br>
        <%}else{%>
					<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				<%}%>			
          </font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="center"><br>ATM Payroll List</div></td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="4" class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("college_name")%> <%=WI.getStrValue(WI.fillTextValue("dept_name"),"(",")","")%></td>
      <td height="24" class="thinborderBOTTOM"><font size="1"><strong><font size="1"><%=WI.getTodaysDate(1)%></font></strong></font></td>
    </tr>
    <tr> 
      <% 
		strTemp = (String)vRetResult.elementAt(0);			
		%>
      <td height="24" colspan="2" class="thinborderBOTTOM" valign="bottom"><font size="1"><strong><%=WI.getStrValue(strTemp," ")%></strong></font></td>
      <td height="24" colspan="2" align="center" class="thinborderBOTTOM"><font size="1">&nbsp;</font> 
        <strong><font size="2">PAYROLL DATE: <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
      <td height="24" class="thinborderBOTTOM" valign="bottom">&nbsp;Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
    <tr> 
      <td width="6%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="15%" class="thinborderBOTTOM"><font size="1"><strong>ACCOUNT 
        #</strong></font></td>
      <td colspan="2" class="thinborderBOTTOM"><font size="1">&nbsp;<strong>EMPLOYEE 
        NAME</strong></font> <div align="center"><font size="1"></font></div></td>
      <td width="21%" align="right" class="thinborderBOTTOM"><font size="1"><strong>NET 
      SALARY</strong></font></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
    <tr> 
      <td><font size="1"><%=iIncr%></font></td>
      <%
	    strTemp = (String)vRetResult.elementAt(i+5);					
	  %>
      <td><font size="1">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
      <td height="20" colspan="2"><font size="1"><strong><%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></td>
    <% 
		// dont try to create shortcut for this block here
		// ayaw i try fix... naay purpose ngano gipa tuyok tuyok ning code
		/// kung magpataka kag buhat pa shortcut ani... dont blame me..
		strTemp = (String)vRetResult.elementAt(i+4);
		strTemp = WI.getStrValue(strTemp, "0");
		strTemp = ConversionTable.replaceString(strTemp,",","");

		dSalary = Double.parseDouble(strTemp);
		strTemp = CommonUtil.formatFloat(dSalary, 2);
		dSalary = Double.parseDouble(strTemp);

		dPageTotal += dSalary;
		dGrandTotal += dSalary;
	  %>
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSalary, true)%></font></div></td>
    </tr>
    <%} // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td width="34%"  class="thinborder">&nbsp;</td>
      <td width="24%" align="right"  class="thinborder"><font size="1">Page 
      Total&nbsp;: </font> </td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%></font></div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Grand Total&nbsp;</font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrandTotal,true)%></font></div></td>
    </tr>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Number of Accounts&nbsp;</font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=iIncr-1%></font></div></td>
    </tr>
    <tr> 
      <td colspan="5"  class="thinborder"><div align="center"><font size="1">*** 
          NOTHING FOLLOWS ***</font></div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Page Total&nbsp;: </font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%></font></div></td>
    </tr>
    <tr> 
      <td colspan="5"  class="thinborder"><div align="center"><font size="1">*** 
          CONTINUED ON NEXT PAGE ***</font></div></td>
    </tr>
    <%}//end else%>
  </table>
<%if(bolIsUB){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td>Printed by: <%=(String)request.getSession(false).getAttribute("first_name")%></td>
	</tr>
  </table>
  
 	<%if ( iNumRec >= vRetResult.size()) {
	//ub needs a cover letter .. insert cover letter here.
	%><DIV style="page-break-before:always" >&nbsp;</DIV>
		  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr > 
			  <td height="25" align="center">UNIVERSITY OF BOHOL<br>City of Tagbilaran <br><br><br> PAYROLL MASTER LIST</td>
			</tr>
			<tr >
			  <td height="25" colspan="5"><br><br><br><%=WI.getTodaysDate(1)%><br><br><br>&nbsp;</td>
			</tr>
		  </table>
		  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr > 
			  <td height="25">
			  	MS KAREN JEAN T. MASLOG <BR>
				Branch Manager<br>
				China Banking Corporation - Tagbilaran City Branch <br>
				G/F Melrose Bldg., Ave., Tagbilaran City <br><br><br>
				
			  	Madam: <br><br><br><br>
			  	
			  	This is to authorize you bank to credit the amount of PESOS: <br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
				<%=new ConversionTable().convertAmoutToFigure(dGrandTotal,"Pesos","Cents")%>
				<br><br>
				(Php <%=CommonUtil.formatFloat(dGrandTotal, true)%>), to the accounts of <br>
				(<%=iIncr-1%>) employees of UNIVERSITY OF BOHOL per attached list in the following pages for the pay period 
				<%=WI.formatDate(strPayrollPeriodTo, 10)%><br><br><br>
				
				Relative there to, a check is drawn against our Current Account # 295-001581-3 with check# <u> auto - debit </u>
				corresponding to the total amount of payroll for this pay period. <br><br><br><br><br>
				
				Respectfully yours, <br><br>
				
				UNIVERSITY OF BOHOL<br>
				by:<br><br><br><br>&nbsp;			  </td>
			</tr>
			<tr >
			  <td height="25">
			  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
					<tr align="center">
					  <td width="33%">ATTY. NUEVAS T. MONTES<br>					    President</td>
						<td width="33%">DR. CRISTETA B. TIROL<br> VP For Finance</td>
						<td width="33%">MRS. VISITACION R. CAGAS <br> Cashier</td>
					</tr>
					<tr align="center">
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr align="center">
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td>Received by: </td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr align="center">
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td>____________________________</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
				  </tr>
				</table>
			  </td>
		    </tr>
		  </table>
  	<%}//end of cover letter%>
  
<%}%>
  
  
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>