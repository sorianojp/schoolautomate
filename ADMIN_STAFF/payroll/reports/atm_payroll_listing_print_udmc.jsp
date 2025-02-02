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
    TD.thinborderBOLDBOTTOM {
    border-bottom: solid 2px #000000;
  	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }				
    TD.thinborderBOTTOMTOP {		
    border-bottom: solid 2px #000000;
		border-top: solid 2px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }		
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function printPage(){
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	
	window.print();	
}

function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);
	
	if (strNewValue != null && strNewValue.length > 0)
		document.getElementById(strLabelName).innerHTML = strNewValue;
}


</script>
<body bgcolor="#FFFFFF">
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
	double dPageTotal = 0d;
	double dGrandTotal = 0d;
	int i = 0; 
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
	<%if (iNumRec == 1) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><font size="1"><strong><font size="1"><%=WI.getTodaysDateTime()%></font></strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="5">Please debit our Account No. <font color="#FF0000">
      <label id="account_no" 
				onclick="setLabelText('account_no','ACCOUNT # ')">
        SA ####-####-#</label> </font>&nbsp;and correspondingly credit into the accounts of our employees listed below which reporesents their net pay for the payroll period : <strong><%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>
    </tr>
  </table>
	<%}%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="22%">&nbsp;</td>
    <td width="56%">&nbsp;</td>
    <td width="22%">&nbsp;</td>
  </tr>
  <tr>
      <% 
		strTemp = (String)vRetResult.elementAt(0);			
		%>	
    <td><font size="1"><strong><%=WI.getStrValue(strTemp," ")%></strong></font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr> 
      <td width="6%" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">Employee Name </td>
      <td colspan="2" class="thinborderBOTTOM">S/ Account#
        <div align="center"><font size="1"></font></div></td>
      <td width="19%" align="right" class="thinborderBOTTOM">N e t &nbsp;PAY&nbsp;&nbsp; </td>
      <td width="9%" align="right" class="thinborderBOTTOM">&nbsp;</td>
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
      <td width="21%">&nbsp;<%=((String)vRetResult.elementAt(i+3)).toUpperCase()%></td>
      <td width="25%"><%=((String)vRetResult.elementAt(i+1)).toUpperCase()%></td>
			<%		  
			strTemp = (String)vRetResult.elementAt(i+5);			
			%>			
      <td height="20" colspan="2"><div align="left">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></div>
        <div align="left"><font size="1"></font></div></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		dPageTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
	  %>
      <td align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%></td>
      <td>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		    
    <tr> 
      <td width="6%" height="26"  class="thinborderBOTTOMTOP">&nbsp;</td>
      <td width="17%"  class="thinborderBOTTOMTOP"><span class="thinborderBOTTOM">&nbsp;Page <%=iPage%> of <%=iTotalPages%></span></td>
      <td width="49%"  class="thinborderBOTTOMTOP"><strong>Total</strong></td>
      <td width="19%" align="right"  class="thinborderBOTTOMTOP"> <%=CommonUtil.formatFloat(dPageTotal,true)%></td>
      <td width="9%"  class="thinborderBOTTOMTOP">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		<%if (iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td  class="thinborderBOLDBOTTOM">&nbsp;</td>
      <td colspan="2"  class="thinborderBOLDBOTTOM"><strong>Grand Total&nbsp;</strong></td>
      <td align="right"  class="thinborderBOLDBOTTOM"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dGrandTotal,true)%></font></div></td>
      <td  class="thinborderBOLDBOTTOM">&nbsp;</td>
    </tr>
		<%}%>		
    <tr>
      <td  class="thinborder">&nbsp;</td>
      <td colspan="2"  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td  class="thinborder">&nbsp;</td>
      <td colspan="2"  class="thinborder">&nbsp;</td>
      <td align="right"  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td  class="thinborder">&nbsp;</td>
      <td colspan="2"  class="thinborder"><strong>Ms. EDITHA F. ENATSU </strong></td>
      <td align="right"  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td  class="thinborder">&nbsp;</td>
      <td colspan="2"  class="thinborder">EVP/Treasurer</td>
      <td align="right"  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>    
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" id="footer">
  <tr>
    <td><hr/></td>
  </tr>
  <tr>
    <td><div align="center">
	<a href="javascript:printPage()"><img src="../../../images/print.gif" width="58" height="26" border="0" /></a><font size="1">print form </font></div></td>
  </tr>
  <tr>
    <td height="30"><font size="2"><strong>Note: 
	  <font style="font-size:11px">Items in <font color="#FF0000">RED</font> are editable for printing purposes only </font><br>Set Printer to black / white mode before printing</strong></font></td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
 </body>
</html>
<%
dbOP.cleanUP();
%>