<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print non taxable income report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }	
    TD.thinborderTOPLEFTRIGHT {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }		
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderLEFT {
    border-left: solid 1px #000000;    
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }

	
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
    
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }

	TD.thinborderNONE {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }

	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","tax_year_to_date_print.jsp");
								
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
														"tax_year_to_date_print.jsp");
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
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;		
	Vector vSalaryPeriod = null;
	boolean bolPageBreak  = false;
	String[] astrTaxStatus = {"Zero Exemption","Single","Head of the Family","Married","Not Set"};
	String strDateFrom = null;
	String strDateTo = null;
	
	vRetResult = RptPay.generatePeriodNonTaxable(dbOP);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

	strTemp = WI.fillTextValue("sal_period_index");

	boolean bolShowTotal = false;
	if(WI.fillTextValue("show_total").length() > 0) 
		bolShowTotal = true;
	
	double dptGrossPay = 0d;
	double dptPagibig = 0d;
	double dptSSS = 0d;
	double dptPhilhealth = 0d;
	double dptUnionDues = 0d;
	double dptTaxInc = 0d;
	double dptTax = 0d;

	double dgtGrossPay = 0d;
	double dgtPagibig = 0d;
	double dgtSSS = 0d;
	double dgtPhilhealth = 0d;
	double dgtUnionDues = 0d;
	double dgtTaxInc = 0d;
	double dgtTax = 0d;
	

	for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strDateFrom = (String)vSalaryPeriod.elementAt(i + 6);
			strDateTo = (String)vSalaryPeriod.elementAt(i + 7);
			break;
		}
	 }//end of for loop.	
	 
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);	
	    if(vRetResult.size() % (15*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="18" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
      </font><font color="#000000" ></font></div></td>
    </tr>
    <tr >
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="14" colspan="2"><div align="center">Non Taxable Income Report </div></td>
    </tr>
    <tr>
      <td width="50%">&nbsp;</td>
      <td width="50%" height="18"><div align="right"></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
  <td height="25" class="thinborderTOPLEFT"><strong><font size="1">From<br>
  To</font></strong></td>
  <td class="thinborderTOP"><strong><font size="1"><%=WI.getStrValue(strDateFrom)%><br>
    <%=WI.getStrValue(strDateTo)%></font></strong></td>
  <td class="thinborderTOP">&nbsp;</td>
  <td colspan="4" class="thinborderTOPLEFT"><div align="center"><font size="1"><strong>Non Taxable Income </strong></font></div></td>
  <td colspan="2" class="thinborderTOPLEFTRIGHT"><div align="right"><font size="1"><strong><%=WI.getTodaysDate(1)%>&nbsp;<br>
    Page <%=iPage%> of <%=iTotalPages%></strong></font>&nbsp;</div></td>
  </tr>
<tr> 
      <td width="5%" height="23" class="thinborder">&nbsp;</td>
      <td width="26%" class="thinborderBOTTOM"><font size="1"><strong>&nbsp;Name</strong></font></td>
      <td width="10%" class="thinborderBOTTOM"><div align="center"><strong><font size="1">Gross Pay </font></strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>Pag-ibig Premium </strong></font></div></td>
      <td width="9%" class="thinborderBOTTOM"><div align="center"><font size="1"><strong>SSS</strong></font></div></td>
      <td width="9%" class="thinborderBOTTOM"><div align="center"><font size="1"><strong>Phil. Health </strong></font></div></td>
      <td width="9%" class="thinborderBOTTOM"><div align="center"><font size="1"><strong>Union Dues </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">Taxable Income </font></strong></div></td>
      <td width="12%" class="thinborderBOTTOMRIGHT"><div align="center"><strong><font size="1">W/Tax</font></strong></div></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr>       
      <td height="16" class="thinborderNONE">&nbsp;<%=iIncr%></td>      
      <td class="thinborderNONE"><div align="left"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		
		dptGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dgtGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+8);
		strTemp = CommonUtil.formatFloat(strTemp,true);

		dptPagibig += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dgtPagibig += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>		  
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+9);
		strTemp = CommonUtil.formatFloat(strTemp,true);

		dptSSS += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dptSSS += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>		  
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = CommonUtil.formatFloat(strTemp,true);

		dptPhilhealth += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dgtPhilhealth += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+13);
		strTemp = WI.getStrValue(strTemp,"0");
		strTemp = CommonUtil.formatFloat(strTemp,true);

		dptUnionDues += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dgtUnionDues += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = CommonUtil.formatFloat(strTemp,true);

		dptTaxInc += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dgtTaxInc += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = CommonUtil.formatFloat(strTemp,true);

		dptTax += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
		dgtTax += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	  %>							
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%></font></div></td>
    </tr>
    <%}// end for Loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
		<%if(bolShowTotal) {%>
			<tr align="right" style="font-weight:bold">
			  <td height="16" class="thinborderNONE">&nbsp;</td>
			  <td class="thinborderNONE">Page Total </td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptGrossPay, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptPagibig, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptSSS, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptPhilhealth, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptUnionDues, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptTaxInc, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptTax, true) %></td>
			</tr>
			<tr align="right" style="font-weight:bold">
			  <td height="16" class="thinborderNONE">&nbsp;</td>
			  <td class="thinborderNONE">Grand Total: </td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtGrossPay, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtPagibig, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtSSS, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtPhilhealth, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtUnionDues, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtTaxInc, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dgtTax, true) %></td>
			</tr>
		<%}%>
    <tr> 
      <td height="13" colspan="9"><div align="center"><font size="1">*** NOTHING 
          FOLLOWS ***</font></div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
		<%if(bolShowTotal) {%>
			<tr align="right" style="font-weight:bold">
			  <td height="16" class="thinborderNONE">&nbsp;</td>
			  <td class="thinborderNONE">Page Total </td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptGrossPay, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptPagibig, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptSSS, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptPhilhealth, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptUnionDues, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptTaxInc, true) %></td>
			  <td class="thinborderNONE"><%=CommonUtil.formatFloat(dptTax, true) %></td>
			</tr>
		<%}
			dptGrossPay = 0d;
			dptPagibig = 0d;
			dptSSS = 0d;
			dptPhilhealth = 0d;
			dptUnionDues = 0d;
			dptTaxInc = 0d;
			dptTax = 0d;
		%>
    <tr> 
      <td height="15" colspan="9"><div align="center"><font size="1">*** CONTINUED 
          ON NEXT PAGE ***</font></div></td>
    </tr>
    <%}%>
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