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
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./payroll_summary_for_bank_Print.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
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
	String strPayrollPeriod  = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dSalary  = 0d;

	vRetResult = RptPay.searchBankAccntSummary(dbOP);
	//System.out.println("vRetResult " +vRetResult);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}
if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
}
	if (vRetResult != null) {
	
		int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
		int iMaxRecPerPage =20; 
		
		if (WI.fillTextValue("num_rec_page").length() > 0){
			iMaxRecPerPage = Integer.parseInt(WI.fillTextValue("num_rec_page"));
		}
		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size()-1;){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          </font><font color="#000000" ></font></div></td>
    </tr>
   </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="2" class="thinborderBOTTOM"><font color="#000000" ><strong>Summary 
        Report</strong></font> </td>
      <td width="34%" height="24" class="thinborderBOTTOM">&nbsp;</td>
      <td width="24%" height="24" colspan="-1" class="thinborderBOTTOM">&nbsp;</td>
      <td height="24" class="thinborderBOTTOM"><font size="1"><strong><font size="1"><%=WI.getTodaysDate(1)%></font></strong></font></td>
    </tr>
    <tr> 
      <% if (vRetResult!= null && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(0);			
		}
		%>
      <td height="24" colspan="2" class="thinborderBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp," ")%></strong></font></td>
      <%

	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
          }
		 }
		%>
      <td height="24" colspan="2" class="thinborderBOTTOM"><font size="1">&nbsp;</font> 
        <div align="center"><strong><font size="2">PAYROLL DATE: <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
      <%

	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 6) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 1) +" - "+(String)vSalaryPeriod.elementAt(i + 2);
          }
		 }
		%>
      <td height="24" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr> 
      <td width="6%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="15%" class="thinborderBOTTOM"><font size="1"><strong>ACCOUNT 
        #</strong></font></td>
      <td colspan="2" class="thinborderBOTTOM"><font size="1">&nbsp;<strong>EMPLOYEE 
        NAME</strong></font> <div align="center"><font size="1"></font></div></td>
      <td width="21%" class="thinborderBOTTOM"><div align="right"><font size="1"><strong>NET 
          SALARY</strong></font></div></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=13,++iIncr, ++iCount){
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
      <%	strTemp = null;
		if (vRetResult!= null && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(i+5);			
//		System.out.println(vRetResult.elementAt(i+5));
		}
	%>
      <td><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp," ")%></font></td>
      <td height="28" colspan="2"><div align="left"><font size="1">&nbsp;<strong><%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div>
        <div align="left"><font size="1"></font></div></td>
      <% strTemp = null;
  	   if(strSchCode.startsWith("UI")){           
			if (vRetResult!= null && vRetResult.size() > 0){
				strTemp = Double.toString(((Double)vRetResult.elementAt(iNumRec+4)).doubleValue());			
			}
		}else{
			if (vRetResult!= null && vRetResult.size() > 0){
				dSalary = ((Double) vRetResult.elementAt(iNumRec+4)).doubleValue() + 
						  ((Double) vRetResult.elementAt(iNumRec+6)).doubleValue() + 
						  ((Double) vRetResult.elementAt(iNumRec+7)).doubleValue() + 
						  ((Double) vRetResult.elementAt(iNumRec+8)).doubleValue() + 
						  ((Double) vRetResult.elementAt(iNumRec+9)).doubleValue() + 
				  		  ((Double) vRetResult.elementAt(iNumRec+10)).doubleValue() + 
						  ((Double) vRetResult.elementAt(iNumRec+11)).doubleValue() + 
						  ((Double) vRetResult.elementAt(iNumRec+12)).doubleValue() ;
				strTemp = Double.toString(dSalary);
			}
		
		}
		%>
      <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <%} // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td colspan="5"  class="thinborder"><div align="center"><font size="1">***************** 
          NOTHING FOLLOWS *******************</font></div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td colspan="5"  class="thinborder"><div align="center"><font size="1">************** 
          CONTINUED ON NEXT PAGE ****************</font></div></td>
    </tr>
    <%}//end else%>
	
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>