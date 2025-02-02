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
    }

    TD.thinborderBOTTOMTOP {
    border-top: solid 1px #000000;
	border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }
	
    TD.grandTotalBorder {
    border-top: solid 1px #000000;
		border-bottom: double 4px #000000;
 		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
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
<form name="form_" 	method="post" action="./atm_payroll_listing_print_cgh.jsp">
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
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","atm_payroll_listing_print_cgh.jsp");
								
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
														"atm_payroll_listing_print_cgh.jsp");
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
	double dSalary = 0d;
	double dGrandTotal = 0d;

	vRetResult = RptPay.searchEmpATMListing(dbOP);
	//System.out.println("vRetResult " +vRetResult);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}

if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
    strTemp = WI.fillTextValue("sal_period_index");	
	for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		  strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 7);
		}
	 }	
}
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = (vRetResult.size()-1)/(9*iMaxRecPerPage);	
	  if(vRetResult.size() % (9*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
  <!--
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td width="2%">&nbsp;</td>
      <td width="98%" height="25" colspan="5"><div align="left"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          BANK DEBIT LIST (<%=WI.formatDate(strPayrollPeriod,10)%>)<br>
          </font><font color="#000000" ></font></div></td>
    </tr>
  </table> 
	 -->
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="2" class="thinborderBOTTOM" valign="bottom">&nbsp;</td>
      <td height="24" colspan="2" class="thinborderBOTTOM"><font size="1">&nbsp;</font> 
        <div align="center"></div></td>
      <td width="20%" height="24" valign="bottom" class="thinborderBOTTOM">&nbsp;Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
  </table>   
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="13%" align="center" class="thinborderBOTTOM">Employee Number </td>
      <td width="40%" align="center" class="thinborderBOTTOM">Employee Name</td>
      <td width="2%" class="thinborderBOTTOM">&nbsp;</td>      
      <td width="10%" align="center" class="thinborderBOTTOM">Depository Br. Code </td>
      <td width="15%" align="center" class="thinborderBOTTOM">Salary</td>
			<td width="15%" align="center" class="thinborderBOTTOM">Account Number </td>
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
      <td height="18">&nbsp;</td>
			<%
			strTemp = (String)vRetResult.elementAt(i);	
			%>
      <td><font size="1"><%=WI.getStrValue(strTemp," ").toUpperCase()%></font></td>
      <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></td>
      <td>&nbsp;</td>
      <td><%=WI.fillTextValue("dep_branch_code")%></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+4);
				strTemp = WI.getStrValue(strTemp, "0");
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dSalary = Double.parseDouble(strTemp);
				strTemp = CommonUtil.formatFloat(dSalary, 2);
				dSalary = Double.parseDouble(strTemp);				
				dGrandTotal += dSalary;
			%>
      <td><div align="right"><%=CommonUtil.formatFloat(dSalary,true)%>&nbsp;</div></td>
      <%	
	  	strTemp = null;		
			strTemp = (String)vRetResult.elementAt(i+5);			
			%>
      <td><div align="left"><font size="1">&nbsp;&nbsp;<%=WI.getStrValue(strTemp," ")%></font></div></td>
    </tr>
    <% } // end for loop%>
		<%
		if (iNumRec >= vRetResult.size()){%>
    <tr>
      <td height="37">&nbsp;</td>
      <td height="37">No. of Records </td>
      <td>&nbsp;<%=iIncr-1%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right" class="grandTotalBorder"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		<%}%>		
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if ( iNumRec >= vRetResult.size()) {%>
    
    <tr>
      <td width="3%"  class="thinborder">&nbsp;</td>
      <td width="94%"  class="thinborder">&nbsp;</td>
      <td width="3%"  class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder"><em>I/We confirm that entries contained herein are true and correct. I/We further agree not to hold the Bank and its officers and staff liable from any claims, demands or losses resulting from errors, omissions, and/or alterations in this report and accompanying diskette. </em></td>
      <td  class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3"  class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="9%" height="44">&nbsp;</td>
          <td width="31%" align="center" class="thinborderBOTTOM">&nbsp;</td>
          <td width="7%">&nbsp;</td>
          <td width="26%" class="thinborderBOTTOM">&nbsp;</td>
          <td width="27%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td align="center">Prepared By </td>
          <td>&nbsp;</td>
          <td align="center">Noted By </td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    
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