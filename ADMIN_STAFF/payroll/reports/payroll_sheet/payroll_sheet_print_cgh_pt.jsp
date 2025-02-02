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
	font-size: 11px;
    }	
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 11px;
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
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
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
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
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
								"Admin/staff-Payroll-REPORTS-payrollsheetprint","payroll_sheet_print_cgh_pt.jsp");
								
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
														"payroll_sheet_print_cgh_pt.jsp");
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
	double dTotalAmount = 0d;
	double dHonorarium = 0d;
	double dTotalTax = 0d;
	double dTotalNet = 0d;	
	double dTotalAdjust = 0d;
	double dRate = 0d;
	double dHoursWork = 0d;
		
	double dLineTotal = 0d;
	
	vRetResult = RptPay.generatePayrollSheetPT(dbOP);
		if(vRetResult == null)
			strErrMsg = RptPay.getErrMsg();
		else
			iSearchResult = RptPay.getSearchCount();

if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
}
%>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="payroll_sheet_print_cgh_pt.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="54" colspan="5"><div align="left"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></td>
    </tr>
</table>
  <% if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="25%" height="33" align="center" class="thinborderBOTTOM">NAME 
      OF EMPLOYEE </td>
      <td width="10%" align="center" class="thinborderBOTTOM">RATE PER HOUR</td>
      <td width="10%" align="center" class="thinborderBOTTOM">NO OF HOURS</td>
      <td width="10%" align="center" class="thinborderBOTTOM">AMOUNT</td>
      <td width="10%" align="center" class="thinborderBOTTOM">ADJUSTMENT</td>
			<%if(WI.fillTextValue("work_type").equals("2")){%>
      <td width="10%" align="center" class="thinborderBOTTOM">HONORARIUM / INCENTIVES </td>
			<%}%>
      <td width="12%" align="center" class="thinborderBOTTOM">W/TAX</td>
      <td width="13%" align="center" class="thinborderBOTTOM">NET PAY</td>
    </tr>
    <% 
	if (vRetResult != null && vRetResult.size() > 0 ){
		//System.out.println("vRetResult " + vRetResult.size());
      for(int i = 0; i < vRetResult.size(); i += 12){
	  dLineTotal = 0d;
	%>
    <tr> 
      <td height="18" class="NoBorder"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></td>
      <%dRate = 0d;
		strTemp = "";
	  	if (vRetResult.elementAt(i+8) != null){	
			strTemp = (String) vRetResult.elementAt(i+8);
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dRate = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		}
	  %>
      <td class="NoBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%></div></td>
      <%
	  	dHoursWork = 0d;
	  	if (vRetResult.elementAt(i+7) != null)
			strTemp = (String) vRetResult.elementAt(i+7); 
		else
			strTemp = "";		
		strTemp = CommonUtil.formatFloat(strTemp, false);		
		dHoursWork = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
	  %>
      <td class="NoBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%></div></td>
      <%
		dLineTotal = dRate * dHoursWork;
		dTotalAmount += dLineTotal;
	  %>
      <td class="NoBorder"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
      <%	  	
	  	if (vRetResult.elementAt(i+6) != null)
			strTemp = (String) vRetResult.elementAt(i+6); 
		else
			strTemp = "";
		strTemp = CommonUtil.formatFloat(strTemp,true);
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		dLineTotal += dTemp;
		dTotalAdjust +=dTemp;
	  %>
      <td class="NoBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
			<%if(WI.fillTextValue("work_type").equals("2")){%>
	    <%	  	
				// other incentives
				strTemp = (String) vRetResult.elementAt(i+10); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
	
					// honorarium
				strTemp = (String) vRetResult.elementAt(i+11); 
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));				
 				if(dTemp == 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(dTemp,true);
	 			dLineTotal += dTemp;
 				dHonorarium += dTemp;				
			%>			
      <td align="right" class="NoBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%}%>
      <%	  	
	  	if (vRetResult.elementAt(i+5) != null)
			strTemp = (String) vRetResult.elementAt(i+5); 
		else
			strTemp = "";
		strTemp = CommonUtil.formatFloat(strTemp,true);
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		dLineTotal -= dTemp;
		dTotalTax += dTemp;
	  %>
      <td class="NoBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
      <%
	  	dTotalNet += dLineTotal;
	  %>
      <td class="NoBorder"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
    </tr>
    <%}//end for loop
	} // end if %>
    <tr> 
      <td height="25" align="right"><font size="1"><strong>TOTAL :   </strong></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMTop"><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMTop"><%=CommonUtil.formatFloat(dTotalAdjust,true)%>&nbsp;</td>
      <%if(WI.fillTextValue("work_type").equals("2")){%>
			<td align="right" class="thinborderBOTTOMTop"><%=CommonUtil.formatFloat(dHonorarium,true)%>&nbsp;</td>
			<%}%>			
      <td align="right" class="thinborderBOTTOMTop"><%=CommonUtil.formatFloat(dTotalTax,true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMTop"><%=CommonUtil.formatFloat(dTotalNet,true)%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="19"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
			<%if(WI.fillTextValue("work_type").equals("2")){%>
      <td>&nbsp;</td>
			<%}%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
      <td width="22%" height="18" bgcolor="#FFFFFF" class="NoBorder">Prepared by: </td>
      <td width="5%" bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td width="35%" bgcolor="#FFFFFF" class="NoBorder">Reviewed by: </td>
      <td width="3%" bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td width="35%" bgcolor="#FFFFFF" class="NoBorder">Noted by: </td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("prepared_by");
			%>				
      <td height="18" bgcolor="#FFFFFF" class="NoBorder"><font size="1"><strong><%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("reviewed_by");
			%>			
      <td bgcolor="#FFFFFF" class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("noted_by");
			%>					
      <td bgcolor="#FFFFFF" class="NoBorder"><font size="1"><strong>&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></strong></font></td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF" class="NoBorder">Personnel/ Payroll Officer </td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">Assistant for Administrative Affairs </td>
      <td bgcolor="#FFFFFF" class="NoBorder">&nbsp;</td>
      <td bgcolor="#FFFFFF" class="NoBorder">Dean</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>