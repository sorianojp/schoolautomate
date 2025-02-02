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
<form name="form_" 	method="post" action="./payroll_summary_for_bank_Print.jsp">
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
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 7);
					break;
       }
		 }

	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 1;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()-1)/(9*iMaxRecPerPage);	
	if((vRetResult.size() % (9*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		
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
      <td height="25" colspan="5" align="right"><font size="1"><strong><font size="1"><%=WI.getTodaysDate(1)%>&nbsp;</font></strong></font></td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="2" class="thinborderBOTTOM"><font size="1">To:<strong> <%=WI.getStrValue((String)vRetResult.elementAt(0))%></strong></font> </td>
      <td width="21%" height="24" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24" colspan="2" class="thinborderBOTTOM">&nbsp;&nbsp;&nbsp;&nbsp;Please debit from our account (Account number <%=WI.fillTextValue("account_no")%>) the amount below and credit to the following
accounts representing their pay for the period ending <%=WI.formatDate(WI.getStrValue(strPayrollPeriod,""),6)%> for credit on <%=WI.formatDate(WI.getStrValue(strPayrollPeriod,""),6)%>.</td>
      <td height="24" class="thinborderBOTTOM" valign="bottom">&nbsp;</td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr> 
      <td width="6%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="45%" class="thinborderBOTTOM"><font size="1">&nbsp;<strong>EMPLOYEE 
      NAME</strong></font> </td>
      <td colspan="2" class="thinborderBOTTOM"><font size="1"><font size="1"><strong>ACCOUNT 
        #</strong></font></font>
      <div align="center"><font size="1"></font></div></td>
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
      <td><div align="right"><font size="1"><%=iIncr%></font>&nbsp;&nbsp;</div></td>
      <td><font size="1">&nbsp;<strong><%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></td>
      <%
	    strTemp = (String)vRetResult.elementAt(i+5);					
	  %>
      <td height="20" colspan="2"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
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
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat(dSalary, true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <%} // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td width="12%"  class="thinborder">&nbsp;</td>
      <td width="16%" align="right"  class="thinborder"><font size="1">Page 
      Total&nbsp;: </font> </td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
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
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Number of Accounts&nbsp;</font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=iIncr-1%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td colspan="5"  class="thinborder"><div align="center"><font size="1">*** 
          NOTHING FOLLOWS ***</font></div></td>
    </tr>
    <tr>
      <td colspan="5"  class="thinborder">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="23">&nbsp;</td>
          <td>&nbsp;</td>
          <td align="center">&nbsp;</td>
          <td align="center">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td width="5%">&nbsp;</td>
          <td width="27%">EUGENIO A. PEDROSA JR.</td>
          <td width="30%" align="center">&nbsp;</td>
          <td width="32%" align="center">MA.CHRISTINA GALEN G. PARROCHO</td>
          <td width="6%">&nbsp;</td>
        </tr>
        <tr>
          <td height="29">&nbsp;</td>
          <td>&nbsp;</td>
          <td align="center">&nbsp;</td>
          <td align="center">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>V-2 G. AGUSTIN</td>
          <td align="center">SUZETTE LILIAN A. AGUSTIN</td>
          <td align="center">TISHA ANGELI A. SY</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder"><font size="1">Page Total&nbsp;: </font></td>
      <td  class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <tr> 
      <td colspan="5"  class="thinborder"><div align="center"><font size="1">*** 
          CONTINUED ON NEXT PAGE ***</font></div></td>
    </tr>
    <%}//end else%>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><span class="thinborderBOTTOM"><%=iPage%> of <%=iTotalPages%></span></td>
  </tr>
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