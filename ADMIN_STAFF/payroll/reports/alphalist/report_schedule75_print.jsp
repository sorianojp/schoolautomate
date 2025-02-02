<%@ page language="java" import="utility.*,payroll.PRTaxReport,hr.HRInfoPersonalExtn,
								java.util.Vector" buffer="16kb"%>
<%
boolean bolHasConfidential = false;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
								
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Report Schedule 7.5</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
td{
	font-size:9px
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 

<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
 
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Tax Schedule7.4","report_schedule74.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");								
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}

	PRTaxReport rptLedger = new PRTaxReport();	
	int iColsSpan = 0;
	int iDefault  = 0;
	Vector vRetResult  = null;
 	Vector vEmpTaxCodes = null;
	Vector vExemptCodes = new Vector();
	Vector vPrevEmpSal = null;
	int iIndexOf = 0;
	double dTemp = 0d;
	double dNonTaxable = 0d;
	double dPrevTaxable = 0d;
	double dTempVal = 0d;
	double[] adGrandTotal = new double[37];
	
	vExemptCodes.addElement("0");	vExemptCodes.addElement("Z");
	vExemptCodes.addElement("1");	vExemptCodes.addElement("S");
	vExemptCodes.addElement("2");	vExemptCodes.addElement("HF");
	vExemptCodes.addElement("21"); vExemptCodes.addElement("HF1");
	vExemptCodes.addElement("22"); vExemptCodes.addElement("HF2");
	vExemptCodes.addElement("23"); vExemptCodes.addElement("HF3");
	vExemptCodes.addElement("24"); vExemptCodes.addElement("HF4");			
	vExemptCodes.addElement("3");	vExemptCodes.addElement("ME");
	vExemptCodes.addElement("31"); vExemptCodes.addElement("ME1");
	vExemptCodes.addElement("32"); vExemptCodes.addElement("ME2");
	vExemptCodes.addElement("33"); vExemptCodes.addElement("ME3");
	vExemptCodes.addElement("34"); vExemptCodes.addElement("ME4");	

	int iMainTemp = 0;
	boolean bolPageBreak = false;
	int i = 0;
	int iMainIncr = 0;

	vRetResult = rptLedger.generateSchedule71(dbOP, request, 5);
	if (vRetResult != null) {	
		int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iTotalPages = (vRetResult.size())/(58*iMaxRecPerPage);	
		int iNumRec = 0;//System.out.println(vRetResult);
	
		if((vRetResult.size() % (58*iMaxRecPerPage)) > 0) 
			 ++iTotalPages;
		iMainIncr = 0; 
	  for (;iNumRec < vRetResult.size();iPage++){			
		
%>

<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr > 
      <td height="25" colspan="2" align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.5 ALPHALIST OF MINIMUM WAGE EARNERS (Reported under Form 2316)</strong></font></td>
    </tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" rowspan="4" align="center">SEQ<br>
      NO</td>
      <td width="2%" rowspan="4" align="center">TIN</td>
      <td height="14" colspan="3" align="center">NAME OF EMPLOYEES </td>
      <td width="5%" rowspan="4" align="center" nowrap>Region No.<br> 
      where<br>
      Assigned </td>
      <td colspan="14" align="center">GROSS COMPENSATION INCOME </td>
    </tr>
    <tr>
      <td width="5%" rowspan="3" align="center">Last Name</td>
      <td width="5%" rowspan="3" align="center">First Name</td>
      <td width="6%" rowspan="3" align="center">Middle Name</td>
      <td height="14" colspan="14" align="center">PREVIOUS EMPLOYER </td>
    </tr>
    <tr>
      <td height="14" colspan="11" align="center"><font size="1"> NON - TAXABLE</font></td> 
      <td colspan="3" align="center"><font size="1"> TAXABLE </font></td>
    </tr>
    <tr>
      <td width="6%" align="center">Gross Compensation Income Previous </td>
      <td width="4%" align="center" >Basic/ SMW </td>
      <td width="5%" align="center" >Holiday Pay </td>
      <td width="5%" align="center" >Overtime Pay </td>
      <td width="5%" align="center" >Night Shift Differential </td>
      <td width="4%" align="center" >Hazard Pay </td>
      <td width="5%" height="14" align="center" >13th Month &amp; Other 
        Benefits</td>
      <td width="4%" align="center" >De Minimis Benefits </td>
      <td width="7%" align="center" >SSS, GSIS, PHIC,Pag-Ibig Contributions and 
        Union Dues</td>
      <td width="7%" align="center" >Salaries &amp; Other Forms of Compensation</td>
      <td width="7%" align="center">Total Non-Taxable/Exempt Compensation Income</td>
      <td width="4%" align="center" >13th Month &amp; Other 
          Benefits</td>
      <td width="7%" align="center" >Salaries  &amp; Other Forms of Compensation </td>
      <td width="5%" align="center" >Total Taxable (Previous Employer) </td>
    </tr>
	  <% 
		iMainTemp = iNumRec;
		for(iCount = 1;iMainTemp < vRetResult.size(); iMainTemp += 58, ++iCount){
		i = iMainTemp;
		vPrevEmpSal = (Vector)vRetResult.elementAt(i+50);
		dPrevTaxable = 0d;
		dNonTaxable = 0d;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>	
    <tr>
      <td ><%=(iMainIncr+iCount)%></td> 
      <td height="20"  nowrap><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td ><%=WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[0] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				// Previous Basic
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(9);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
				
				dTempVal = dNonTaxable;				
				adGrandTotal[1] += dTempVal;					
			%>
			<td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				// Non Taxable Holiday
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(10);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
				
				dTempVal = dNonTaxable;				
				adGrandTotal[2] += dTempVal;
			%>			
			<td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				// Non Taxable OT
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(11);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
					
				dTempVal = dNonTaxable;				
				adGrandTotal[3] += dTempVal;
			%>			
			<td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				// Non Taxable NP
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(12);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
					
				dTempVal = dNonTaxable;				
				adGrandTotal[4] += dTempVal;
			%>
			<td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				// Non Taxable Hazard
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(13);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
					
				dTempVal = dNonTaxable;				
				adGrandTotal[5] += dTempVal;
			%>			
			<td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%></td>
			<%
				dNonTaxable = 0d;
				// non taxable bonus
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(1);
					dNonTaxable = Double.parseDouble(strTemp);
				}else
					strTemp = "";
				
				dTempVal = dNonTaxable;				
				adGrandTotal[6] += dTempVal;
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// de_minimis_
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(2);
					dTempVal = Double.parseDouble(strTemp);
					dNonTaxable += dTempVal;
				}else
					strTemp = "";
				
				adGrandTotal[7] += dTempVal;
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// contributions
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(3);
					dTempVal = Double.parseDouble(strTemp);
					dNonTaxable += dTempVal;
				}else
					strTemp = "";
				
				adGrandTotal[8] += dTempVal;
			%>			
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// non_taxable_salary
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(4);
					dTempVal = Double.parseDouble(strTemp);
					dNonTaxable += dTempVal;
				}else
					strTemp = "";
				
				adGrandTotal[9] += dTempVal;
			%>	
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				adGrandTotal[10] += dNonTaxable;
			%>
      <td align="right" ><%=CommonUtil.formatFloat(dNonTaxable, true)%></td>
      <%
				// taxable_bonus
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(5);
					dTempVal = Double.parseDouble(strTemp);
					dPrevTaxable += dTempVal;
				}else
					strTemp = "";
					
				adGrandTotal[11] += dTempVal;
			%>
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
			<%
				// taxable_sal
				if(vPrevEmpSal != null && vPrevEmpSal.size() > 0){
					strTemp = (String)vPrevEmpSal.elementAt(6);
					dTempVal = Double.parseDouble(strTemp);
					dPrevTaxable += dTempVal;
				}else
					strTemp = "";
					
				adGrandTotal[12] += dTempVal;
			%>			
      <td align="right" ><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</td>
      <%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+13), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[13] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
    </tr>
		<%}%>
		<% if (iMainTemp >= vRetResult.size()){ %>
    <tr>
      <td >&nbsp;</td>
      <td height="20"  nowrap>&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[0], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[1], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[2], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[3], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[4], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[5], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[6], true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[7], true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[8], true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[9], true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[10], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[11], true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[12], true)%>&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[13], true)%></td>
    </tr>
    <%}%>
  </table>
	<%if (bolPageBreak || iMainTemp == vRetResult.size()){%>
  <DIV style="page-break-before:always">&nbsp;</DIV>
  <% }//page break ony if it is not last page.%> 	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr > 
      <td height="25" colspan="2" align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.5 ALPHALIST OF MINIMUM WAGE EARNERS (Reported under Form 2316)</strong></font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">    
    <tr>
      <td width="2%" rowspan="3" align="center" >SEQ<br>NO</td> 
      <td height="7" colspan="17" align="center" >PRESENT EMPLOYER </td>
      <td width="6%" rowspan="3" align="center" ><font size="1">Total  Compensation Present </font></td>
      <td width="6%" rowspan="3" align="center" >Total Taxable (Previous &amp; Present Employers) </td>
    </tr>
    <tr>
      <td height="7" colspan="2" align="center" >Inclusive Date of Employment </td>
      <td height="7" colspan="13" align="center" >NON TAXABLE</td>
      <td height="7" colspan="2" align="center" >TAXABLE</td>
    </tr>
    <tr>
      <td width="5%" align="center" >From</td>
      <td width="5%" align="center" >To</td>
      <td width="5%" align="center" >Gross Compensation Income </td>
      <td width="4%" align="center" >Basic SMW Per Day </td>
      <td width="4%" align="center" >Basic SMW Per Month </td>
      <td width="5%" align="center" >Basic SMW Per Year </td>
      <td width="5%" align="center" >Factor Used (No. Of Days/Year) </td>
      <td width="5%" align="center" >Holiday Pay </td>
      <td width="5%" align="center" >Overtime Pay </td>
      <td width="5%" align="center" >Night Shift Differential </td>
      <td width="5%" align="center" >Hazard Pay </td>
      <td width="5%" height="14" align="center" >13th Month &amp; Other 
        Benefits</td>
      <td width="5%" align="center" >De Minimis Benefits </td>
      <td width="6%" align="center" >SSS, GSIS, PHIC,Pag-Ibig Contributions and 
        Union Dues</td>
      <td width="6%" align="center" >Salaries &amp; Other Forms of Compensation</td>
      <td width="5%" align="center" >13th Month &amp; Other 
      Benefits</td>
      <td width="6%" align="center" >Salaries  &amp; Other Forms of Compensation </td>
    </tr>
	  <% 
		iMainTemp = iNumRec;
		for(iCount = 1;iMainTemp < vRetResult.size(); iMainTemp += 58, ++iCount){
		i = iMainTemp;
		vPrevEmpSal = (Vector)vRetResult.elementAt(i+50);
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>		
    <tr>
      <td height="14" ><%=(iMainIncr+iCount)%></td> 
			<td align="right" ><span style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></span></td>
			<td align="right" ><span style="font-size: 9px;"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></span></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+11), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[14] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+51), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[15] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+52), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[16] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<td align="right" >&nbsp;</td>
			<td align="right" >&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+23), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[17] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+24), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[18] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+25), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[19] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+26), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[20] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+27), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[21] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+28), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[22] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+29), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[23] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				// basic non taxable for present employer
				strTemp = (String)vRetResult.elementAt(i+22);
				dTemp = Double.parseDouble(strTemp);

				// other_comp for present employer
				strTemp = (String)vRetResult.elementAt(i+30);
				dTemp += Double.parseDouble(strTemp);
				
				adGrandTotal[24] += dTemp;
			%>
			<td align="right" ><%=CommonUtil.formatFloat(dTemp, true)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+41), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[25] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
          //" np_pay, hazard_non_tax, bonus_non_tax, de_minimis, contributions, " + // 25 - 29
          //" other_comp, basic_taxable, representation, transportation, cola, " + // 30 - 34
          //" housing_allow, regular_amt_a, regular_amt_b, commission, profit_share, " + // 35 - 39
          //" fees, bonus_taxable, hazard_taxable, ot_taxable, sup_amt_a, sup_amt_b, " + // 40 - 45
								
				dTemp = Double.parseDouble((String)vRetResult.elementAt(i+32));// representation
				strTemp = (String)vRetResult.elementAt(i+33); // transportation
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+34); // cola
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+35); // housing_allow
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+36); // regular_amt_a
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+37); // regular_amt_b
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+38); // commission
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+39); // profit_share
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+40); // fees
				dTemp += Double.parseDouble(strTemp);
				
				strTemp = (String)vRetResult.elementAt(i+42); // hazard_taxable
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+43); // ot_taxable
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+44); // sup_amt_a 
				dTemp += Double.parseDouble(strTemp);
				strTemp = (String)vRetResult.elementAt(i+45); // sup_amt_b
				dTemp += Double.parseDouble(strTemp);

				strTemp = (String)vRetResult.elementAt(i+31); // taxable_basic
				dTemp += Double.parseDouble(strTemp);				
				adGrandTotal[26] += dTemp;
			%>
			<td align="right" ><%=CommonUtil.formatFloat(dTemp, true)%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+12), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[27] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+14), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[28] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			 
    </tr>
		<%}%>
		<% if (iMainTemp >= vRetResult.size()){ %>
    <tr>
      <td height="14" >&nbsp;</td>
      <td align="right" >&nbsp;</td>
      <td align="right" >&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[14], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[15], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[16], true)%></td>
      <td align="right" >&nbsp;</td>
      <td align="right" >&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[17], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[18], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[19], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[20], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[21], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[22], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[23], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[24], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[25], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[26], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[27], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[28], true)%></td>
    </tr>
    <%}%>
  </table>	
	<%if (bolPageBreak || iMainTemp == vRetResult.size()){%>
  <DIV style="page-break-before:always">&nbsp;</DIV>
  <% }//page break ony if it is not last page.%> 		
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr > 
      <td height="25" colspan="2" align="center"><font color="#000000" size="1" ><strong>Schedule 
          7.5 ALPHALIST OF MINIMUM WAGE EARNERS (Reported under Form 2316)</strong></font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">    
    <tr>
      <td width="2%" rowspan="2" align="center" >SEQ<br>
      NO</td> 
      <td height="7" colspan="2" align="center" >EXEMPTION</td>
      <td width="11%" rowspan="2" align="center">Premium Paid on Health and/or Hospital Insurance</td>
      <td width="11%" rowspan="2" align="center">Net Taxable Compensation Income </td>
      <td width="11%" rowspan="2" align="center">Tax Due<br>
      (JAN. - DEC.)</td>
      <td width="11%" rowspan="2" align="center" >TAX WITHHELD<br>
      (JAN. - NOV.)</td>
      <td colspan="2" align="center" >YEAR - END ADJUSTMENT</td>
      <td width="11%" rowspan="2" align="center" >Amount of Tax Withheld as Adjusted</td>
    </tr>
    
    <tr>
      <td width="8%" height="7" align="center" >Code</td>
      <td width="8%" align="center" >Amount</td>
      <td width="11%" align="center" >AMOUNT WITHHELD AND PAID FOR IN DECEMBER</td>
      <td width="11%" align="center" >OVERWITHHELD TAX REFUNDED TO EMPLOYEE </td>
    </tr>
    <% 
		for(iCount = 1;iNumRec < vRetResult.size();iNumRec += 58, ++iCount, iMainIncr++){
		i = iNumRec;
 		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		} else 
			bolPageBreak = false;			
	  %>
    <tr>
      <td ><%=iMainIncr+1%></td> 
			<%
				strTemp = (String)vRetResult.elementAt(i+48);
				iIndexOf = vExemptCodes.indexOf(strTemp);
				if(iIndexOf != -1){
					strTemp = (String) vExemptCodes.elementAt(iIndexOf+1);
				}else{
					strTemp = "n/a";
				}
			%>
      <td height="14" >&nbsp;<%=WI.getStrValue(strTemp)%></td>
			
      <%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+15), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[29] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[30] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+17), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[31] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+18), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));


				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[32] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+46), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

				dTemp = dTempVal;
				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[33] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+47), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

				dTemp += dTempVal;
				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[34] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+49), true);
				dTempVal = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));

				dTemp -= dTempVal;
				if(dTempVal == 0d)
					strTemp = "&nbsp;";
					
				adGrandTotal[35] += dTempVal;
			%>
      <td align="right"><%=strTemp%></td>
			<%
				adGrandTotal[36] += dTemp;
			%>
      <td align="right" ><%=CommonUtil.formatFloat(dTemp, true)%></td>
    </tr>
		<%}%>
		<% if (iNumRec >= vRetResult.size()){ %>
    <tr>
      <td >&nbsp;</td>
      <td height="14" >&nbsp;</td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[29], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[30], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[31], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[32], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[33], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[34], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[35], true)%></td>
      <td align="right" ><%=CommonUtil.formatFloat(adGrandTotal[36], true)%></td>
    </tr>
    <%}%>
  </table>
	
	<%if (iNumRec < vRetResult.size()){%>
  <DIV style="page-break-before:always">&nbsp;</Div>
  <% }//page break ony if it is not last page.
	  } //end for (iNumRec < vRetResult.size()
  } //end end upper most if (vRetResult !=null)%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>