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
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ViewRecords()
{
	document.form_.print_pg.value="";	
	document.form_.viewRecords.value="1";
	this.SubmitOnce("form_");
}

</script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./payroll_summary_addl_pay_print.jsp">
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
	
	double dTotal = 0d;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","payroll_summary_addl_pay_print.jsp");
								
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
														"payroll_summary_addl_pay_print.jsp");
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
	double dTemp = 0d;

	vRetResult = RptPay.searchAddlPay(dbOP);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

	if (vRetResult != null) {	
		int i = 0; int k = 0; int iCount = 0;
		int iMaxRecPerPage =20; 
		
		if (WI.fillTextValue("num_rec_page").length() > 0){
			iMaxRecPerPage = Integer.parseInt(WI.fillTextValue("num_rec_page"));
		}
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="11"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          </font></div></td>
    </tr>
    <tr> 
      <td height="24" colspan="8" class="thinborderBOTTOM"><strong>Additional 
        Pay Summary</strong></td>
      <td colspan="3" class="thinborderBOTTOM"><font size="1"><strong><%=WI.getTodaysDate(1)%></strong></font></td>
    </tr>
    <tr> 
      <%
	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
					break;
      }
		}
	  %>
      <td height="24" colspan="11" align="center" class="thinborderBOTTOM"><font size="1">&nbsp;</font><font size="1">&nbsp;</font> 
        <strong><font size="2">PAYROLL DATE: <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
      <%

	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
          }
		 }
		%>
    </tr>
    <tr> 
      <td width="3%"><font size="1">&nbsp;</font></td>
      <td width="25%" align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></td>
      <td width="8%" align="center"><font size="1">OT</font></td>
      <td width="9%" colspan="2" align="center"><font size="1">BONUS</font></td>
      <td width="9%" align="center"><font size="1">NIGHT DIFF.</font></td>
      <td width="9%" align="center"><font size="1">HOLIDAY PAY</font></td>
      <td width="9%" align="center"><font size="1">ADDL RESP</font></td>
      <td width="9%" align="center"><font size="1">ADDL PAY</font></td>
      <td width="9%" align="center"><font size="1">TOTAL INCENTIVE</font></td>
      <td width="10%" align="center"><font size="1">TOTAL</font></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=10,++iIncr, ++iCount){
		dTotal = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr> 
      <td height="26"><div align="right"><font size="1"><%=iCount%></font></div></td>
      <td>&nbsp;<font size="1"><strong><%=WI.formatName(((String)vRetResult.elementAt(i)).toUpperCase(), (String)vRetResult.elementAt(i+1),
							((String)vRetResult.elementAt(i+2)).toUpperCase(), 4)%></strong></font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+3);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+4);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td colspan="2" align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+5);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+6);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+7);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+8);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <%  
 				strTemp = (String)vRetResult.elementAt(i+9);			
  			strTemp = WI.getStrValue(strTemp,"0");
				dTemp = Double.parseDouble(strTemp);
				dTotal += dTemp;
				if(dTemp <= 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(strTemp,true);
			%>
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <td align="right"><font size="1"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotal,true),"")%></strong>&nbsp;</font></td>
    </tr>
    <% } // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td colspan="11"  class="thinborder"><div align="center">***************** 
          NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td colspan="11"  class="thinborder"><div align="center">************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
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